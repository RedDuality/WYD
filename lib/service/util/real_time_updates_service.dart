import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/update_type.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/state/event_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class RealTimeUpdateService {
  static final RealTimeUpdateService _instance =
      RealTimeUpdateService._internal();

  factory RealTimeUpdateService({BuildContext? context}) {
    return _instance;
  }

  late String deviceId;
  late DateTime creationTime;

  RealTimeUpdateService._internal();

  bool firstread = true;

  start() async {
    var user = UserProvider().user;
    if (user == null) throw "User is null";

    creationTime = DateTime.now();

    FirebaseFirestore.instance
        .collection(user.hash)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (firstread) {
        firstread = false;
        return;
      }
      var update = snapshot.docs[0];

      //Yes, current device will update 2 times
      handleUpdate(update);
    });
  }

  void handleUpdate(var snapshot) {
    var typeIndex = snapshot['type'];
    switch (UpdateType.values[typeIndex]) {
      case UpdateType.newEvent:
        EventService().retrieveNewByHash(snapshot['hash']);
        break;
      case UpdateType.shareEvent:
        EventService().retrieveSharedByHash(snapshot['hash']);
        break;
      case UpdateType.updateEvent:
        EventService().retrieveUpdateByHash(snapshot['hash']);
        break;
      case UpdateType.updatePhotos:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null) {
          EventService().retrieveImageUpdatesByHash(event);
        }
        break;
      case UpdateType.confirmEvent:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null && snapshot['phash'] != null) {
          EventService()
              .localConfirm(event, true, profileHash: snapshot['phash']);
        }
        break;
      case UpdateType.declineEvent:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null && snapshot['phash'] != null) {
          EventService()
              .localConfirm(event, false, profileHash: snapshot['phash']);
        }
        break;
      case UpdateType.deleteEvent:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null && snapshot['phash'] != null) {
          EventService()
              .localDelete(event, profileHash: snapshot['phash']);
        }
        break;
      case UpdateType.profileDetails:
        //_handleProfileUpdate(snapshot['id']);
        break;
      default:
        debugPrint("default notification not catch $typeIndex");
        break;
    }
  }
}
