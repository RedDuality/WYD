import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/service/community/community_service.dart';
import 'package:wyd_front/service/event/event_long_polling_service.dart';
import 'package:wyd_front/service/media/media_auto_select_service.dart';
import 'package:wyd_front/service/util/notification_service.dart';
import 'package:wyd_front/service/util/permission_service.dart';
import 'package:wyd_front/service/util/real_time_updates_service.dart';

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  bool _initialized = false;

  void attach() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);

    _initializeServices();
    _initializeSecondaryServices();
  }

  Future<void> _initializeServices() async {
    CommunityService().retrieveCommunities();
  }

  Future<void> _initializeSecondaryServices() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RealTimeUpdateService().initialize();
      EventLongPollingService.resumePolling();

      if (!kIsWeb) {
        PermissionService.requestPermissions().then((value) {
          NotificationService().initialize();
          MediaAutoSelectService.checkEventsForPhotos();
        });
      }
    });
  }

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
