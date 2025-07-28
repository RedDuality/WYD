import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/event_api.dart';
import 'package:wyd_front/API/user_api.dart';
import 'package:wyd_front/state/eventEditor/blob_provider.dart';
import 'package:wyd_front/state/eventEditor/detail_provider.dart';
import 'package:wyd_front/state/event_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class EventService {
  static void initializeDetails(Event? initialEvent, DateTime? date, bool confirmed) {
    DetailProvider().initialize(initialEvent, date, confirmed);
    BlobProvider().initialize(
        hash: initialEvent?.eventHash,
        cachedImages: initialEvent?.cachedNewImages,
        imageHashes: initialEvent?.images);
  }

  static void localUpdate(Event updatedEvent) {
    EventProvider().updateEvent(updatedEvent);
    DetailProvider().updateCurrentEvent(updatedEvent);
  }

  static void localConfirm(Event event, bool confirmed, {String? profileHash}) {
    event.confirm(confirmed, profHash: profileHash);
    localUpdate(event);
  }

  static Future<void> retrieveMultiple() async {
    var events = await UserAPI().listEvents();

    EventProvider().addAll(events);
  }

  static Future<Event> create(Event event) async {
    var createdEvent = await EventAPI().create(event);
    EventProvider().addEvent(createdEvent);
    return createdEvent;
  }

  //real time update, another device created a new event
  static Future<void> retrieveNewByHash(String eventHash) async {
    var event = await EventAPI().retrieveFromHash(eventHash);

    EventProvider().addEvent(event);
  }

  //someone shared a link, have to also add on the backend
  static Future<Event> retrieveAndAddByHash(String eventHash) async {
    var event = EventProvider().findEventByHash(eventHash);
    if (event == null) {
      var sharedEvent = await EventAPI().sharedWithHash(eventHash);
      EventProvider().addEvent(sharedEvent);
      return sharedEvent;
    } else {
      //should already be updated
      return event;
    }
  }

  //someone shared an event with group
  static Future<void> retrieveSharedByHash(String eventHash) async {
    if (EventProvider().findEventByHash(eventHash) == null) {
      var event = await EventAPI().retrieveFromHash(eventHash);
      EventProvider().addEvent(event);
    } else {
      retrieveUpdateByHash(eventHash);
    }
  }

  static Future<void> update(Event updatedEvent) async {
    var event = await EventAPI().update(updatedEvent);

    localUpdate(event);
  }

  static Future<void> retrieveUpdateByHash(String eventHash) async {
    var event = await EventAPI().retrieveFromHash(eventHash);

    localUpdate(event);
  }

  static Future<void> confirm(Event event) async {
    await EventAPI().confirm(event.eventHash);

    localConfirm(event, true);
  }

  static Future<void> decline(Event event) async {
    await EventAPI().decline(event.eventHash);

    localConfirm(event, false);
  }

  static Future<void> shareToGroups(String eventHash, Set<int> groupsIds) async {
    var event = await EventAPI().shareToGroups(eventHash, groupsIds);

    localUpdate(event);
  }

  static void setCachedImages(Event event, List<AssetEntity> photosDuringEvent) {
    event.cachedNewImages = photosDuringEvent;
    EventProvider().updateEvent(event);
    if (BlobProvider().isCurrentEvent(event.eventHash)) {
      BlobProvider().setCachedImages(event.cachedNewImages);
    }
  }

  static void clearCachedImages(String eventHash) {
    var event = EventProvider().retrieveEventByHash(eventHash);

    event.cachedNewImages = [];
    EventProvider().updateEvent(event);
    if (BlobProvider().isCurrentEvent(event.eventHash)) {
      BlobProvider().clearCachedImages();
    }
  }

  static void localImageUpdate(Event event, List<String> updatedImages) {
    event.images = updatedImages;
    EventProvider().updateEvent(event);
    if (BlobProvider().isCurrentEvent(event.eventHash)) {
      BlobProvider().updateImageHashes(event.images);
    }
  }

  static void localUploadCachedImages(Event event, List<String> updatedImages) {
    event.cachedNewImages = [];
    event.images = updatedImages;
    EventProvider().updateEvent(event);
    BlobProvider().initialize(hash: event.eventHash, imageHashes: updatedImages, cachedImages: []);
  }

  static Future<void> uploadImages(String eventHash, List<BlobData> blobs) async {
    var event = EventProvider().retrieveEventByHash(eventHash);

    var updatedImages = await EventAPI().uploadImages(event.eventHash, blobs);
    localImageUpdate(event, updatedImages);
  }

  static Future<void> uploadCachedImages(String eventHash, List<BlobData> blobs) async {
    var event = EventProvider().retrieveEventByHash(eventHash);

    var updatedImages = await EventAPI().uploadImages(event.eventHash, blobs);
    localUploadCachedImages(event, updatedImages);
  }

  static Future<void> retrieveImageUpdatesByHash(Event event) async {
    var updatedImages = await EventAPI().retrieveImageUpdatesFromHash(event.eventHash);

    localImageUpdate(event, updatedImages);
  }

  static void localDelete(Event event, {String? profileHash}) {
    var pHash = profileHash ?? UserProvider().getCurrentProfileHash();
    event.removeProfile(pHash);

    if (event.countMatchingProfiles(UserProvider().getProfileHashes()) == 0) {
      EventProvider().remove(event);
      DetailProvider().close();
      BlobProvider().close();
    } else {
      localUpdate(event);
    }
  }

  static Future<void> delete(Event event) async {
    await EventAPI().delete(event.eventHash);
    localDelete(event);
  }
}
