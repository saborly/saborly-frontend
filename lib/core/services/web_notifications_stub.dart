// lib/core/services/web_notifications_stub.dart
// Stub file for web platform to avoid compilation errors

class FlutterLocalNotificationsPlugin {
  // Stub implementation - does nothing on web
  
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
  }) async {
    // Return false to indicate local notifications aren't available on web
    return false;
  }

  T? resolvePlatformSpecificImplementation<T>() {
    // Return null since platform-specific implementations don't exist on web
    return null;
  }

  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    // Do nothing on web - notifications are handled by browser
  }
}

class NotificationResponse {
  final String? payload;
  const NotificationResponse({this.payload});
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String icon);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings({
    bool? requestAlertPermission,
    bool? requestBadgePermission,
    bool? requestSoundPermission,
  });
}

class InitializationSettings {
  const InitializationSettings({
    AndroidInitializationSettings? android,
    DarwinInitializationSettings? iOS,
  });
}

class AndroidNotificationChannel {
  const AndroidNotificationChannel(
    String id,
    String name, {
    String? description,
    Importance? importance,
    bool? enableVibration,
    bool? playSound,
  });
}

enum Importance { high }

class AndroidNotificationDetails {
  const AndroidNotificationDetails(
    String channelId,
    String channelName, {
    String? channelDescription,
    Importance? importance,
    Priority? priority,
    bool? showWhen,
    bool? enableVibration,
    bool? playSound,
  });
}

enum Priority { high }

class DarwinNotificationDetails {
  const DarwinNotificationDetails({
    bool? presentAlert,
    bool? presentBadge,
    bool? presentSound,
  });
}

class NotificationDetails {
  const NotificationDetails({
    AndroidNotificationDetails? android,
    DarwinNotificationDetails? iOS,
  });
}

// Add the missing AndroidFlutterLocalNotificationsPlugin class with createNotificationChannel method
class AndroidFlutterLocalNotificationsPlugin {
  // Stub method for web - does nothing
  Future<void> createNotificationChannel(AndroidNotificationChannel channel) async {
    // Do nothing on web - this is a no-op stub
    return;
  }
}

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static String get operatingSystem => 'web';
}