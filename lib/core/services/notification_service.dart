// lib/core/services/notification_service.dart - COMPLETE FIXED VERSION
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Saborly/shared/models/notification_model.dart'; // ✅ ADD THIS IMPORT

import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'package:Saborly/core/services/web_notifications_stub.dart';
import 'dart:io' if (dart.library.html) 'dart:html' show Platform;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) print('📬 Background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? _localNotifications;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Callbacks
  Function(Map<String, dynamic>)? onNotificationReceived;
  Function(Map<String, dynamic>)? onNotificationTapped;
  Function(AppNotification)? notificationProviderCallback; // ✅ ADD THIS

  Future<void> initialize() async {
    try {
      if (kDebugMode) print('🔔 Initializing NotificationService...');

      final settings = await _requestPermission();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print('✅ Notification permission granted');
        
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
        
        if (kDebugMode) print('✅ NotificationService initialized successfully');
      } else {
        if (kDebugMode) print('❌ Notification permission denied');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Notification initialization error: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  Future<NotificationSettings> _requestPermission() async {
    if (kDebugMode) print('📋 Requesting notification permission...');
    
    try {
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
      
      return settings;
    } catch (e) {
      if (kDebugMode) print('❌ Permission request error: $e');
      return const NotificationSettings(
        authorizationStatus: AuthorizationStatus.denied,
        alert: AppleNotificationSetting.disabled,
        announcement: AppleNotificationSetting.disabled,
        badge: AppleNotificationSetting.disabled,
        carPlay: AppleNotificationSetting.disabled,
        lockScreen: AppleNotificationSetting.disabled,
        notificationCenter: AppleNotificationSetting.disabled,
        showPreviews: AppleShowPreviewSetting.never,
        timeSensitive: AppleNotificationSetting.disabled,
        criticalAlert: AppleNotificationSetting.disabled,
        sound: AppleNotificationSetting.disabled,
        providesAppNotificationSettings: AppleNotificationSetting.disabled,
      );
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
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (kDebugMode) {
          print('📨 Foreground message received');
          print('   Title: ${message.notification?.title}');
          print('   Body: ${message.notification?.body}');
          print('   Data: ${message.data}');
        }
        
        await _handleForegroundMessage(message);
        await _saveNotificationToProvider(message); // ✅ SAVE TO PROVIDER
      }, onError: (error) {
        if (kDebugMode) print('❌ Foreground message error: $error');
      });

      // Handle when user taps notification (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        if (kDebugMode) {
          print('👆 Notification tapped (app in background)');
          print('   Data: ${message.data}');
        }
        
        await _handleMessage(message);
        await _saveNotificationToProvider(message); // ✅ SAVE TO PROVIDER
      }, onError: (error) {
        if (kDebugMode) print('❌ Message opened error: $error');
      });
      
      if (kDebugMode) print('✅ Message handlers setup complete');
    } catch (e) {
      if (kDebugMode) print('❌ Message handler setup error: $e');
    }
  }

  // ✅ NEW METHOD: Save notification to provider
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
        if (kDebugMode) print('   Make sure callback is set in main.dart _setupNotificationHandlers');
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
      
      if (kDebugMode) {
        print('📝 Created AppNotification:');
        print('   ID: ${appNotification.id}');
        print('   Title: ${appNotification.title}');
        print('   Type: ${appNotification.type}');
        print('   Data: ${appNotification.data}');
      }
      
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
        if (kDebugMode) print('🔔 Calling onNotificationReceived callback');
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
        if (kDebugMode) print('👆 Calling onNotificationTapped callback');
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
      if (kDebugMode) print('⚠️ Cannot show local notification (web or not initialized)');
      return;
    }

    try {
      if (kDebugMode) print('📱 Showing local notification: $title');
      
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
      
      if (kDebugMode) print('✅ Local notification shown');
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
      if (kDebugMode) print('❌ Unsubscribe from topic error: $e');
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