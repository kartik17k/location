import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    // Initialise the plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) => null,
    );

    await requestPermission();
  }

  static Future<void> requestPermission() async {
    if (await _needsAndroidPermission()) {
      final PermissionStatus status = await Permission.notification.request();

      if (status.isGranted) {
        print("Notification permission granted");
      } else if (status.isDenied) {
        print("Notification permission denied");
      } else if (status.isPermanentlyDenied) {
        print("Notification permission permanently denied");
        // Open app settings for the user to grant permission manually
        await openAppSettings();
      }
    }
  }

  static Future<bool> _needsAndroidPermission() async {
    return (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied);
  }

  static Future Notification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your_channel_id', 'your_channel_name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
