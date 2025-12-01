import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:wyd_front/API/User/store_fcm_token_request_dto.dart';
import 'package:wyd_front/API/User/user_api.dart';
import 'package:wyd_front/firebase_options.dart';
import 'package:wyd_front/service/util/real_time/real_time_message_handler.dart';
import 'package:wyd_front/service/util/real_time/real_time_service.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class FcmService implements RealTimeService{

  @override
  void initialize() {
    _storeTokenOnStartup();
    _monitorTokenRefreshes();
    _monitorMessages();
    //_monitorBackgroundMessages();
  }

/*
  void _monitorBackgroundMessages() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // This runs in a background isolate
    if (message.data.isNotEmpty) {
      RealTimeMessageHandler.handleUpdate(message.data);
    }

    // If you want to show a push notification manually:
    if (message.notification == null && message.data.containsKey("title")) {
      // Use flutter_local_notifications to display
    }
  }
*/
  
  Future<void> _storeTokenOnStartup() async {
    var userId = UserCache().getUserId();

    try {
      await FirebaseMessaging.instance.requestPermission();

      // (if !kisWeb) FCM token retrieval is independent of notification permissions
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        var requestDto = StoreFcmTokenRequestDto(
          uuid: userId,
          platform: _getPlatform(),
          fcmToken: fcmToken,
        );

        await UserAPI().storeFCMToken(requestDto);
      }
    } catch (e) {
      debugPrint('User did not gave permission for notifications');
    }
  }

  static String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
      //return 'ios';
      case TargetPlatform.macOS:
      //return 'macos';
      case TargetPlatform.windows:
      //return 'windows';
      case TargetPlatform.linux:
      //return 'linux';
      default:
        throw UnsupportedError(
          'Your platform is not yet supported.',
        );
    }
  }

  void _monitorTokenRefreshes() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      var userId = UserCache().getUserId();

      var requestDto = StoreFcmTokenRequestDto(
        uuid: userId,
        platform: DefaultFirebaseOptions.currentPlatform.toString(),
        fcmToken: fcmToken,
      );
      await UserAPI().storeFCMToken(requestDto);
      debugPrint("FCM Token refreshed and stored: $fcmToken");
    }).onError((err) {
      throw ("Error monitoring token refresh: $err");
    });
  }

  void _monitorMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message notification title: ${message.notification!.title}');
        debugPrint('Message notification body: ${message.notification!.body}');
        debugPrint('Message notification body: ${message.notification!}');
      }
      RealTimeMessageHandler.handleUpdate(message.data);
    });
  }

  @override
  Future<void> dispose() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        await UserAPI().deleteFCMToken(fcmToken);
        debugPrint('FCM Token successfully deleted from backend.');
      }

      await FirebaseMessaging.instance.deleteToken();
      debugPrint('FCM Token successfully deleted locally.');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}
