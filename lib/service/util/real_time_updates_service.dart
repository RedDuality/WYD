import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/User/store_fcm_token_request_dto.dart';
import 'package:wyd_front/API/User/user_api.dart';
import 'package:wyd_front/firebase_options.dart';
import 'package:wyd_front/model/enum/update_type.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/calendar_view_event_controller.dart';
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

    // (if !kisWeb) FCM token retrieval is independent of notification permissions
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      var requestDto = StoreFcmTokenRequestDto(
        uuid: user.hash,
        platform: getPlatform(),
        fcmToken: fcmToken,
      );

      await UserAPI().storeFCMToken(requestDto);
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
      handleUpdate(message.data);
    });
  }

  void handleUpdate(Map<String, dynamic> data) {
    var updateType = _findUpdateType(data['type']);

    switch (updateType) {
      case UpdateType.createEvent:
        EventRetrieveService.retrieveEssentialByHash(data['hash']);
        break;
      case UpdateType.shareEvent:
        EventRetrieveService.retrieveSharedByHash(data['hash']);
        break;
      case UpdateType.updateEssentialsEvent:
        EventRetrieveService.retrieveUpdateByHash(data['hash']);
        break;
      /*
      case UpdateType.updateDetailsEvent:
        EventService.retrieveDetailsByHash(data['hash']);
        break;
      */
      case UpdateType.confirmEvent:
        if (data['hash'] != null && data['phash'] != null) {
          EventViewService.localConfirm(data['hash'], true, pHash: data['phash']);
        }
        break;
      case UpdateType.declineEvent:
        if (data['hash'] != null && data['phash'] != null) {
          EventViewService.localConfirm(data['hash'], false, pHash: data['phash']);
        }
        break;

      case UpdateType.updatePhotos:
        var event = CalendarViewEventController().findEventByHash(data['hash']);
        if (event != null) {
          MediaService.retrieveImageUpdatesByHash(event);
        }
        break;
      case UpdateType.deleteEvent:
        var event = CalendarViewEventController().findEventByHash(data['hash']);
        if (event != null && data['phash'] != null) {
          EventViewService.localDelete(event, profileHash: data['phash']);
        }
        break;
      case UpdateType.profileDetails:
        //_handleProfileUpdate(snapshot['phash']);
        break;
      default:
        debugPrint("Type of update has not been catched");
    }
  }

  UpdateType? _findUpdateType(String typeString) {
    for (var type in UpdateType.values) {
      if (type.toString().split('.').last.toLowerCase() == typeString.toLowerCase()) {
        return type;
      }
    }
    return null;
  }
}
