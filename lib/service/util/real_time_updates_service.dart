import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/update_type.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/service/event/event_service.dart';
import 'package:wyd_front/state/event/event_provider.dart';

class RealTimeUpdateService {
  static final RealTimeUpdateService _instance =
      RealTimeUpdateService._internal();

  factory RealTimeUpdateService({BuildContext? context}) {
    return _instance;
  }


  RealTimeUpdateService._internal();


  Future<void> start() async {
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
