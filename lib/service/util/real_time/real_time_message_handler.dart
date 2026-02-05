import 'package:flutter/foundation.dart';
import 'package:wyd_front/model/enum/update_type.dart';
import 'package:wyd_front/service/event/event_actions_service.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/service/profile/detailed_profile_storage_service.dart';
import 'package:wyd_front/state/event/event_storage.dart';

class RealTimeMessageHandler {
  static Future<void> handleUpdate(Map<String, dynamic> data) async {
    var updateType = _findUpdateType(data['type']);
    debugPrint('New notification: ${updateType!.name}');
    switch (updateType) {
      case UpdateType.updateEssentialsEvent:
        var updatedTime = DateTime.parse(data['time'] as String).toUtc();
        String? actorId = data['profileId'];
        EventRetrieveService.checkAndRetrieveEssentialByHash(data['id'], updatedTime, actorId);
        break;
      case UpdateType.confirmEvent:
        if (data['id'] != null && data['profileId'] != null) {
          EventActionsService.localConfirm(data['id'], true, pHash: data['profileId']);
        }
        break;
      case UpdateType.declineEvent:
        if (data['id'] != null && data['profileId'] != null) {
          EventActionsService.localConfirm(data['id'], false, pHash: data['profileId']);
        }
        break;
      case UpdateType.deleteEvent:
        var event = await EventStorage().getEventById(data['id']);
        if (event != null && data['phash'] != null) {
          EventActionsService.localDelete(event, profileHash: data['phash']);
        }
        break;
      case UpdateType.updatePhotos:
        var event = await EventStorage().getEventById(data['id']);
        if (event != null) {
          MediaService.retrieveImageUpdatesByHash(event);
        }
        break;
      case UpdateType.updateProfile:
        DetailedProfileStorageService.retrieveFromServer(data['id']);
        break;
      case UpdateType.updateMask:
        var updatedTime = DateTime.parse(data['time'] as String).toUtc();
        MaskService.checkAndRetrieveUpdates(data['id'], updatedTime);
        break;
      case UpdateType.deleteMask:
        break;
      default:
        debugPrint("Type of update has not been catched");
    }
  }

  static UpdateType? _findUpdateType(String typeString) {
    for (var type in UpdateType.values) {
      if (type.toString().split('.').last.toLowerCase() == typeString.toLowerCase()) {
        return type;
      }
    }
    return null;
  }
}
