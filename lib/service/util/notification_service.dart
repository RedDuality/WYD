import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

/*
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final hasPermission =
          await androidImplementation.areNotificationsEnabled();

      if (hasPermission == null || !hasPermission) {
        final permissionGranted =
            await androidImplementation.requestNotificationsPermission();
        if (permissionGranted! && !permissionGranted) {
          // Handle the case where the user denies the permission
          return;
        }
      }
      
    
    }
    */
    return;
  }

  static void showNotification(String title, String description) async {
    debugPrint("SENTNOTIFICATION");

    var android = AndroidNotificationDetails(title, description,
        channelDescription: 'channelDescription');
    var iOS = DarwinNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);

    await FlutterLocalNotificationsPlugin()
        .show(0, title, description, platform);
  }
}
