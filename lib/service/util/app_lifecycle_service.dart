import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/service/community/community_service.dart';
import 'package:wyd_front/service/event/event_long_polling_service.dart';
import 'package:wyd_front/service/mask/mask_long_polling_service.dart';
import 'package:wyd_front/service/media/media_auto_select_service.dart';
import 'package:wyd_front/service/user/user_service.dart';
import 'package:wyd_front/service/util/notification_service.dart';
import 'package:wyd_front/service/util/device_permission_service.dart';
import 'package:wyd_front/service/util/real_time/real_time_update_service.dart';
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
    CommunityService().retrieveCommunities();
  }

  static Future<void> _initializeCollections() async {
    CommunityService().retrieveCommunities();
  }

  static void _initializeServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      RealTimeUpdateService().initialize();
      EventLongPollingService.resumePolling();
      MaskLongPollingService.resumePolling();

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
      EventLongPollingService.resumePolling();
      MaskLongPollingService.resumePolling();

      if (!kIsWeb) MediaAutoSelectService.checkEventsForPhotos();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      EventLongPollingService.pausePolling();
      MaskLongPollingService.pausePolling();
    }
  }

  void detach() {
    debugPrint("detached");
    if (!_initialized) return;
    _initialized = false;
    WidgetsBinding.instance.removeObserver(this);

    // Stop polling when detached
    EventLongPollingService.pausePolling();
    MaskLongPollingService.pausePolling();
  }
}
