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
   
      // Check current permission status WITHOUT requesting
      final settings = await _messaging.getNotificationSettings();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _completeInitialization();
      } else {
        // Don't request permission here - wait for user-initiated request
      }
      
      _isInitialized = true;
    } catch (e, stackTrace) {
      
    }
  }

  /// Request permission and complete setup - call this from your dialog
  Future<bool> requestPermissionWithDialog() async {
    try {
      
      // Check if already granted
      final currentSettings = await _messaging.getNotificationSettings();
      if (currentSettings.authorizationStatus == AuthorizationStatus.authorized) {
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
      
    
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _completeInitialization();
        
        // Save that user has been asked
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notification_permission_asked', true);
        await prefs.setBool('notification_permission_granted', true);
        
        return true;
      } else {
        
        // Save that user has been asked
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notification_permission_asked', true);
        await prefs.setBool('notification_permission_granted', false);
        
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Check if we should show the permission dialog
  Future<bool> shouldShowPermissionDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAsked = prefs.getBool('notification_permission_asked') ?? false;
      
      if (hasAsked) {
        return false;
      }
      
      // Check current status
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Complete initialization after permission granted
  Future<void> _completeInitialization() async {
    try {
      if (!kIsWeb) {
        await _initializeLocalNotifications();
      } else {
      }
      
      await _getFCMToken();
      _setupMessageHandlers();
      
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        await _handleMessage(initialMessage);
        await _saveNotificationToProvider(initialMessage);
      }
      
    } catch (e) {
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) {
      return;
    }

    try {
      
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
          if (details.payload != null) {
            _handleNotificationTap(details.payload!);
          }
        },
      );
      

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
          }
        }
      } catch (e) {
      }
    } catch (e) {
    }
  }

  Future<void> _getFCMToken() async {
    try {
      
      if (kIsWeb) {
        const vapidKey = 'BIxx0P8Ifh3XE6K8mZnlMx1ayvu9pRPTAIikbuqHkgf_OjUXZ_X23WE-prcaJyqVsCbjCk6kn0g8syuST25ncSo';
        
        
        _fcmToken = await _messaging.getToken(vapidKey: vapidKey);
      } else {
        _fcmToken = await _messaging.getToken();
      }
      
      if (_fcmToken != null) {
     
        await _saveFCMToken(_fcmToken!);
      } else {
      }

      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveFCMToken(newToken);
      });
    } catch (e, stackTrace) {
   
    }
  }

  void _setupMessageHandlers() {
    
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
       
        
        await _handleForegroundMessage(message);
        await _saveNotificationToProvider(message);
      }, onError: (error) {
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
     
        await _handleMessage(message);
        await _saveNotificationToProvider(message);
      }, onError: (error) {
      });
      
    } catch (e) {
    }
  }

  Future<void> _saveNotificationToProvider(RemoteMessage message) async {
    try {
      
      final notification = message.notification;
      if (notification == null) {
        return;
      }
      
      if (notificationProviderCallback == null) {
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
    } catch (e, stack) {
      
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        if (kIsWeb) {
        } else {
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
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      
      
      if (onNotificationTapped != null) {
        onNotificationTapped!(data);
      }
    } catch (e) {
    }
  }

  void _handleNotificationTap(String payload) {
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
    }
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
    } catch (e) {
    }
  }
}