import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/update_type.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/state/event_provider.dart';

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
    var typeIndex = snapshot['type'];
    switch (UpdateType.values[typeIndex]) {
      case UpdateType.newEvent:
        EventService().retrieveNewByHash(snapshot['hash']);
        break;
      case UpdateType.updateEvent:
        EventService().retrieveUpdateByHash(snapshot['hash']);
        break;
      case UpdateType.confirmEvent:
        debugPrint("confirmed");
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null) {
          event.confirm();
          EventProvider().updateEvent(event);
        }
        break;
      case UpdateType.declineEvent:
        debugPrint("declined");
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null) {
          event.decline();
          EventProvider().updateEvent(event);
        }
        break;
      case UpdateType.profileDetails:
        //_handleProfileUpdate(snapshot['id']);
        break;
      default:
        debugPrint("default notification not catch $typeIndex" );
        break;
    }
  }

}
