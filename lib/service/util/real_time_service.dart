import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/update_type.dart';
import 'package:wyd_front/service/model/event_service.dart';

class RealTimeService {
  static final RealTimeService _instance = RealTimeService._internal();

  factory RealTimeService({BuildContext? context}) {
    return _instance;
  }

  late String deviceId;
  late DateTime creationTime;

  RealTimeService._internal();

  static String _generateUniqueId() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  bool firstread = true;

  initialize(String userHash) async {
    creationTime = DateTime.now();
    deviceId = _generateUniqueId();

    FirebaseFirestore.instance
        .collection(userHash)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (firstread) {
        firstread = false;
        return;
      }
      var update = snapshot.docs[0];
      if (!update.data().containsKey("deviceId") ||
          update["deviceId"] != deviceId) {
        handleUpdate(update);
      }
    });
  }

  void handleUpdate(var snapshot) {
    var type = snapshot['type'];
    switch (type) {
      case UpdateType.newEvent:
        _handleEventUpdate(snapshot['hash']);
        break;
      case UpdateType.updateEvent:
        //_handleEventUpdate(snapshot['hash']);
        break;
      case UpdateType.confirmEvent:
        //_handleConfirmUpdate(snapshot['id']);
        break;
      case UpdateType.declineEvent:
        //_handleDeclineUpdate(snapshot['hash']);
        break;
      case UpdateType.profileDetails:
        //_handleProfileUpdate(snapshot['id']);
        break;
      default:
    }
  }

  Future<void> _handleEventUpdate(String hash) async {
    await EventService().retrieveNewByHash(hash);
  }
}
