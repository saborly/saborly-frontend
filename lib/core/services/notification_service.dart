// lib/core/services/notification_service.dart - FIXED FOR WEB
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Conditional import for platform-specific packages
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'package:soely/core/services/web_notifications_stub.dart';
import 'dart:io' if (dart.library.html) 'dart:html' show Platform;

// Top-level function for background message handling (mobile only)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

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

  Future<void> initialize() async {
    try {


      // Request permissions
      final settings = await _requestPermission();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        
        // Initialize local notifications (only for mobile)
        if (!kIsWeb) {
          await _initializeLocalNotifications();
        } else {
        }
        
        // Get FCM token
        await _getFCMToken();
        
        // Setup message handlers
        _setupMessageHandlers();
        
        // Handle initial message if app opened from terminated state
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessage(initialMessage);
        }
        
      } else {
      }
    } catch (e, stackTrace) {
   
    }
  }

  Future<NotificationSettings> _requestPermission() async {
    
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
      
      return settings;
    } catch (e) {
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
      

      // Create notification channel for Android (wrapped in try-catch for web safety)
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
        // IMPORTANT: Replace with your actual VAPID key from Firebase Console
        // Go to: Firebase Console -> Project Settings -> Cloud Messaging -> Web Push certificates
        const vapidKey = 'BIxx0P8Ifh3XE6K8mZnlMx1ayvu9pRPTAIikbuqHkgf_OjUXZ_X23WE-prcaJyqVsCbjCk6kn0g8syuST25ncSo'; // TODO: Replace this!
        
       
        
        _fcmToken = await _messaging.getToken(vapidKey: vapidKey);
      } else {
        _fcmToken = await _messaging.getToken();
      }
      
      if (_fcmToken != null) {
        await _saveFCMToken(_fcmToken!);
      } else {
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveFCMToken(newToken);
      });
    } catch (e, stackTrace) {
 
    }
  }

  void _setupMessageHandlers() {
    
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
       
        
        _handleForegroundMessage(message);
      }, onError: (error) {
      });

      // Handle when user taps notification (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(message);
      }, onError: (error) {
      });
      
    } catch (e) {
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        if (kIsWeb) {
          // Browser automatically shows notifications on web
        } else {
          // For mobile, show local notification
          await _showLocalNotification(
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
            payload: data,
          );
        }
      }

      // Call callback
      if (onNotificationReceived != null) {
        onNotificationReceived!(data);
      }
    } catch (e) {
    }
  }

  void _handleMessage(RemoteMessage message) {
    try {
      final data = message.data;
      
      // Call callback
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