// lib/core/services/notification_service.dart - Updated with delayed permission
import 'package:Saborly/features/providers/notification_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Saborly/shared/models/notification_model.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'package:Saborly/core/services/web_notifications_stub.dart';
import 'dart:io' if (dart.library.html) 'dart:html' show Platform;

class NotificationService {
   static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  factory NotificationService() => _instance;
  NotificationService._internal();

  // -------------------------------------------------
  // 2. Callback (will be set from main.dart)
  // -------------------------------------------------
  Function(AppNotification)? notificationProviderCallback;

  // -------------------------------------------------
  // 3. Attach the provider (call once from main.dart)
  // -------------------------------------------------
  void attachProvider(NotificationProvider provider) {
    notificationProviderCallback = provider.addNotification;
  }
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? _localNotifications;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Callbacks
  Function(Map<String, dynamic>)? onNotificationReceived;
  Function(Map<String, dynamic>)? onNotificationTapped;

  /// Initialize WITHOUT requesting permission
  /// Permission will be requested later via requestPermissionWithDialog()
  Future<void> initialize() async {
    try {
      if (kDebugMode) print('🔔 Initializing NotificationService (no permission request)...');

      // Check current permission status WITHOUT requesting
      final settings = await _messaging.getNotificationSettings();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print('✅ Notification permission already granted');
        await _completeInitialization();
      } else {
        if (kDebugMode) print('⏳ Notification permission not yet granted');
        // Don't request permission here - wait for user-initiated request
      }
      
      _isInitialized = true;
      if (kDebugMode) print('✅ NotificationService initialized (ready for permission request)');
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Notification initialization error: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  /// Request permission and complete setup - call this from your dialog
  Future<bool> requestPermissionWithDialog() async {
    try {
      if (kDebugMode) print('📋 Requesting notification permission...');
      
      // Check if already granted
      final currentSettings = await _messaging.getNotificationSettings();
      if (currentSettings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print('✅ Permission already granted');
        await _completeInitialization();
        return true;
      }
      
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );
      
      if (kDebugMode) {
        print('Permission status: ${settings.authorizationStatus}');
      }
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print('✅ Permission granted! Completing setup...');
        await _completeInitialization();
        
        // Save that user has been asked
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notification_permission_asked', true);
        await prefs.setBool('notification_permission_granted', true);
        
        return true;
      } else {
        if (kDebugMode) print('❌ Permission denied');
        
        // Save that user has been asked
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notification_permission_asked', true);
        await prefs.setBool('notification_permission_granted', false);
        
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Permission request error: $e');
      return false;
    }
  }

  /// Check if we should show the permission dialog
  Future<bool> shouldShowPermissionDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAsked = prefs.getBool('notification_permission_asked') ?? false;
      
      if (hasAsked) {
        if (kDebugMode) print('⏭️ Already asked for permission before');
        return false;
      }
      
      // Check current status
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print('✅ Already authorized');
        return false;
      }
      
      if (kDebugMode) print('✅ Should show permission dialog');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking permission dialog status: $e');
      return false;
    }
  }

  /// Complete initialization after permission granted
  Future<void> _completeInitialization() async {
    try {
      if (!kIsWeb) {
        await _initializeLocalNotifications();
      } else {
        if (kDebugMode) print('🌐 Running on web - skipping local notifications');
      }
      
      await _getFCMToken();
      _setupMessageHandlers();
      
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) print('📬 App opened from notification');
        await _handleMessage(initialMessage);
        await _saveNotificationToProvider(initialMessage);
      }
      
      if (kDebugMode) print('✅ Notification setup completed');
    } catch (e) {
      if (kDebugMode) print('❌ Complete initialization error: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) {
      if (kDebugMode) print('🌐 Skipping local notifications for web');
      return;
    }

    try {
      if (kDebugMode) print('📱 Initializing local notifications...');
      
      _localNotifications = FlutterLocalNotificationsPlugin();
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _localNotifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          if (kDebugMode) print('👆 Local notification tapped: ${details.payload}');
          if (details.payload != null) {
            _handleNotificationTap(details.payload!);
          }
        },
      );
      
      if (kDebugMode) print('Local notifications initialized: $initialized');

      try {
        if (!kIsWeb && Platform.isAndroid) {
          const channel = AndroidNotificationChannel(
            'order_updates',
            'Order Updates',
            description: 'Notifications about your order status',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          );

          final androidPlugin = _localNotifications!
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          
          if (androidPlugin != null) {
            await androidPlugin.createNotificationChannel(channel);
            if (kDebugMode) print('✅ Android notification channel created');
          }
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ Could not create Android channel: $e');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Local notifications error: $e');
    }
  }

  Future<void> _getFCMToken() async {
    try {
      if (kDebugMode) print('🔑 Getting FCM token...');
      
      if (kIsWeb) {
        const vapidKey = 'BIxx0P8Ifh3XE6K8mZnlMx1ayvu9pRPTAIikbuqHkgf_OjUXZ_X23WE-prcaJyqVsCbjCk6kn0g8syuST25ncSo';
        
        if (kDebugMode) print('🌐 Getting web token with VAPID key');
        
        _fcmToken = await _messaging.getToken(vapidKey: vapidKey);
      } else {
        _fcmToken = await _messaging.getToken();
      }
      
      if (_fcmToken != null) {
        if (kDebugMode) {
          print('✅ FCM Token obtained');
          print('Token: ${_fcmToken!.substring(0, 50)}...');
        }
        await _saveFCMToken(_fcmToken!);
      } else {
        if (kDebugMode) print('❌ Failed to get FCM token');
      }

      _messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) print('🔄 FCM token refreshed');
        _fcmToken = newToken;
        _saveFCMToken(newToken);
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ FCM token error: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  void _setupMessageHandlers() {
    if (kDebugMode) print('📨 Setting up message handlers...');
    
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (kDebugMode) {
          print('📨 Foreground message received');
          print('   Title: ${message.notification?.title}');
          print('   Body: ${message.notification?.body}');
          print('   Data: ${message.data}');
        }
        
        await _handleForegroundMessage(message);
        await _saveNotificationToProvider(message);
      }, onError: (error) {
        if (kDebugMode) print('❌ Foreground message error: $error');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        if (kDebugMode) {
          print('👆 Notification tapped (app in background)');
          print('   Data: ${message.data}');
        }
        
        await _handleMessage(message);
        await _saveNotificationToProvider(message);
      }, onError: (error) {
        if (kDebugMode) print('❌ Message opened error: $error');
      });
      
      if (kDebugMode) print('✅ Message handlers setup complete');
    } catch (e) {
      if (kDebugMode) print('❌ Message handler setup error: $e');
    }
  }

  Future<void> _saveNotificationToProvider(RemoteMessage message) async {
    try {
      if (kDebugMode) print('💾 _saveNotificationToProvider called');
      
      final notification = message.notification;
      if (notification == null) {
        if (kDebugMode) print('⚠️ No notification object in message');
        return;
      }
      
      if (notificationProviderCallback == null) {
        if (kDebugMode) print('❌ notificationProviderCallback is null!');
        return;
      }
      
      final appNotification = AppNotification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        type: message.data['type']?.toString() ?? 'general',
        data: Map<String, dynamic>.from(message.data),
        timestamp: DateTime.now(),
        imageUrl: notification.android?.imageUrl ?? notification.apple?.imageUrl,
      );
      
      await notificationProviderCallback!(appNotification);
      if (kDebugMode) print('✅ Callback executed successfully');
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error in _saveNotificationToProvider: $e');
        print('Stack trace: $stack');
      }
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        if (kIsWeb) {
          if (kDebugMode) print('🌐 Browser will show notification automatically');
        } else {
          if (kDebugMode) print('📱 Showing local notification');
          await _showLocalNotification(
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
            payload: data,
          );
        }
      }

      if (onNotificationReceived != null) {
        onNotificationReceived!(data);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Foreground message error: $e');
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      
      if (kDebugMode) print('📬 Handling message data: $data');
      
      if (onNotificationTapped != null) {
        onNotificationTapped!(data);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Message handling error: $e');
    }
  }

  void _handleNotificationTap(String payload) {
    if (kDebugMode) print('🔔 Notification tapped with payload: $payload');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    if (kIsWeb || _localNotifications == null) {
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'order_updates',
        'Order Updates',
        channelDescription: 'Notifications about your order status',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications!.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload != null ? payload.toString() : null,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Show notification error: $e');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      if (kDebugMode) print('✅ FCM token saved to preferences');
    } catch (e) {
      if (kDebugMode) print('❌ Save FCM token error: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) print('✅ Subscribed to topic: $topic');
    } catch (e) {
      if (kDebugMode) print('❌ Subscribe to topic error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      if (kDebugMode) print('❌ Unsubscribe to topic error: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      if (kDebugMode) print('✅ FCM token deleted');
    } catch (e) {
      if (kDebugMode) print('❌ Delete token error: $e');
    }
  }
}