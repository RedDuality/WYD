import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/User/store_fcm_token_request_dto.dart';
import 'package:wyd_front/API/User/user_api.dart';
import 'package:wyd_front/firebase_options.dart';
import 'package:wyd_front/model/enum/update_type.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/service/event/event_service.dart';
import 'package:wyd_front/state/event/event_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class RealTimeUpdateService {
  static final RealTimeUpdateService _instance = RealTimeUpdateService._internal();

  factory RealTimeUpdateService({BuildContext? context}) {
    return _instance;
  }

  RealTimeUpdateService._internal();

  void initialize() {
    _storeTokenOnStartup();
    _monitorTokenRefreshes();
    _monitorMessages();
  }

  Future<void> _storeTokenOnStartup() async {
    var user = UserProvider().user;
    if (user == null) {
      throw "User is not authenticated. Cannot store FCM token.";
    }

    // Request user permissions for notifications
    await FirebaseMessaging.instance.requestPermission();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      var requestDto = StoreFcmTokenRequestDto(
        uuid: user.hash,
        platform: getPlatform(),
        fcmToken: fcmToken,
      );

      await UserAPI().storeFCMToken(requestDto);
      debugPrint("FCM Token stored successfully: $fcmToken");
    }
  }

  static String getPlatform() {
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
      var user = UserProvider().user;
      if (user != null) {
        var requestDto = StoreFcmTokenRequestDto(
          uuid: user.hash,
          platform: DefaultFirebaseOptions.currentPlatform.toString(),
          fcmToken: fcmToken,
        );
        await UserAPI().storeFCMToken(requestDto);
        debugPrint("FCM Token refreshed and stored: $fcmToken");
      }
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
      //handleUpdate(message.data);
    });
  }

  void handleUpdate(var snapshot) {
    var typeIndex = snapshot['type'];
    switch (UpdateType.values[typeIndex]) {
      case UpdateType.newEvent:
        EventService.retrieveByHash(snapshot['hash']);
        break;
      case UpdateType.shareEvent:
        EventService.retrieveSharedByHash(snapshot['hash']);
        break;
      case UpdateType.updateEvent:
        EventService.retrieveUpdateByHash(snapshot['hash']);
        break;
      case UpdateType.updatePhotos:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null) {
          MediaService.retrieveImageUpdatesByHash(event);
        }
        break;
      case UpdateType.confirmEvent:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null && snapshot['phash'] != null) {
          EventViewService.localConfirm(event, true, profileHash: snapshot['phash']);
        }
        break;
      case UpdateType.declineEvent:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null && snapshot['phash'] != null) {
          EventViewService.localConfirm(event, false, profileHash: snapshot['phash']);
        }
        break;
      case UpdateType.deleteEvent:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null && snapshot['phash'] != null) {
          EventService.localDelete(event, profileHash: snapshot['phash']);
        }
        break;
      case UpdateType.profileDetails:
        //_handleProfileUpdate(snapshot['phash']);
        break;
      default:
        debugPrint("default notification not catch $typeIndex");
        break;
    }
  }
}
