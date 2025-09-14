import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/update_type.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/service/event/event_service.dart';
import 'package:wyd_front/state/event/event_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

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

  Future<void> start() async {
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

  void handleUpdate(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
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
          EventViewService
              .localConfirm(event, true, profileHash: snapshot['phash']);
        }
        break;
      case UpdateType.declineEvent:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null && snapshot['phash'] != null) {
          EventViewService
              .localConfirm(event, false, profileHash: snapshot['phash']);
        }
        break;
      case UpdateType.deleteEvent:
        var event = EventProvider().findEventByHash(snapshot['hash']);
        if (event != null && snapshot['phash'] != null) {
          EventService
              .localDelete(event, profileHash: snapshot['phash']);
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
