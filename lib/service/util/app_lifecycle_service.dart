import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/service/community/community_service.dart';
import 'package:wyd_front/service/event/event_long_polling_service.dart';
import 'package:wyd_front/service/media/media_auto_select_service.dart';
import 'package:wyd_front/service/user/user_service.dart';
import 'package:wyd_front/service/util/notification_service.dart';
import 'package:wyd_front/service/util/device_permission_service.dart';
import 'package:wyd_front/service/util/real_time_updates_service.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  bool _initialized = false;

  Future<void> attach() async {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);

    _retrieveData();
    _initializeServices();
  }

  static void _retrieveData() {
    if (kIsWeb || AuthenticationProvider().isFirstTimeLogging) {
      _initializeCollections();
    } else {
      _retrieveUpdates();
    }
  }

  static void _retrieveUpdates() {
    UserService.retrieveUser();
  }

  static void _initializeCollections() {
    if(kIsWeb) UserService.retrieveUser(); // user is saved in shared_preferences, but viewSettings and userclaims are not

    CommunityService().retrieveCommunities();
  }

  static void _initializeServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RealTimeUpdateService().initialize();
      EventLongPollingService.resumePolling();

      if (!kIsWeb) {
        DevicePermissionService.requestPermissions().then((value) {
          NotificationService().initialize();
          MediaAutoSelectService.checkEventsForPhotos();
        });
      }
    });
  }

  // resumed 
  // app: turns on from the ram
  // web: depending on the browser, tabs returns in view/focus
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!kIsWeb) {
        MediaAutoSelectService.checkEventsForPhotos();
      }
      EventLongPollingService.resumePolling();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      EventLongPollingService.pausePolling();
    }
  }

  void detach() {
    if (!_initialized) return;
    _initialized = false;
    WidgetsBinding.instance.removeObserver(this);

    // Stop polling when detached
    EventLongPollingService.pausePolling();
  }
}
