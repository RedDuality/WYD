import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/service/util/real_time/fcm_service.dart';
import 'package:wyd_front/service/util/real_time/real_time_service.dart';
import 'package:wyd_front/service/util/real_time/sse_service.dart';

class RealTimeUpdateService {
  late RealTimeService service;

  static final RealTimeUpdateService _instance = RealTimeUpdateService._internal();
  factory RealTimeUpdateService({BuildContext? context}) => _instance;
  RealTimeUpdateService._internal();

  void initialize() {
    service = kIsWeb ? SseService() : FcmService();
    service.initialize();
  }

  void dispose() {
    service.dispose();
  }
}
