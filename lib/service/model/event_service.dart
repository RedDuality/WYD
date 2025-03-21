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
  void initializeDetails(Event? initialEvent, DateTime? date, bool confirmed) {
    DetailProvider().initialize(initialEvent, date, confirmed);
    BlobProvider().initialize(
        hash: initialEvent?.hash,
        cachedImages: initialEvent?.cachedNewImages,
        imageHashes: initialEvent?.images);
  }

  void localUpdate(Event updatedEvent) {
    EventProvider().updateEvent(updatedEvent);
    DetailProvider().updateCurrentEvent(updatedEvent);
  }

  void localConfirm(Event event, bool confirmed, {String? profileHash}) {
    event.confirm(confirmed, profHash: profileHash);
    localUpdate(event);
  }

  Future<void> retrieveMultiple() async {
    var events = await UserAPI().listEvents();

    EventProvider().addAll(events);
  }

  Future<Event> create(Event event) async {
    var createdEvent = await EventAPI().create(event);
    EventProvider().addEvent(createdEvent);
    return createdEvent;
  }

  //rtupdate, another device created a new event
  Future<void> retrieveNewByHash(String eventHash) async {
    var event = await EventAPI().retrieveFromHash(eventHash);

    EventProvider().addEvent(event);
  }

  //someone shared a link, have to add on the backend also
  Future<Event> retrieveAndAddByHash(String eventHash) async {
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
  Future<void> retrieveSharedByHash(String eventHash) async {
    if (EventProvider().findEventByHash(eventHash) == null) {
      var event = await EventAPI().retrieveFromHash(eventHash);
      EventProvider().addEvent(event);
    } else {
      retrieveUpdateByHash(eventHash);
    }
  }

  Future<void> update(Event updatedEvent) async {
    var event = await EventAPI().update(updatedEvent);

    localUpdate(event);
  }

  Future<void> retrieveUpdateByHash(String eventHash) async {
    var event = await EventAPI().retrieveFromHash(eventHash);

    localUpdate(event);
  }

  Future<void> confirm(Event event) async {
    await EventAPI().confirm(event.hash);

    localConfirm(event, true);
  }

  Future<void> decline(Event event) async {
    await EventAPI().decline(event.hash);

    localConfirm(event, false);
  }

  Future<void> shareToGroups(String eventHash, Set<int> groupsIds) async {
    var event = await EventAPI().shareToGroups(eventHash, groupsIds);

    localUpdate(event);
  }

  static void setCachedImages(
      Event event, List<AssetEntity> photosDuringEvent) {
    event.cachedNewImages = photosDuringEvent;
    EventProvider().updateEvent(event);
    BlobProvider().setCachedImages(event.cachedNewImages, hash: event.hash);
  }

  void clearCachedImages(Event event) {
    event.cachedNewImages = [];
    EventProvider().updateEvent(event);
    BlobProvider().clearCachedImages(hash: event.hash);
  }

  void localImageUpdate(Event event, List<String> updatedImages) {
    event.images = updatedImages;
    EventProvider().updateEvent(event);
    BlobProvider().updateImageHashes(event.images, hash: event.hash);
  }

  void localUploadCachedImages(Event event, List<String> updatedImages) {
    event.cachedNewImages = [];
    event.images = updatedImages;
    EventProvider().updateEvent(event);
    BlobProvider().initialize(
        hash: event.hash, imageHashes: updatedImages, cachedImages: []);
  }

  Future<void> uploadImages(Event event, List<BlobData> blobs) async {
    var updatedImages = await EventAPI().uploadImages(event.hash, blobs);
    localImageUpdate(event, updatedImages);
  }

  Future<void> uploadCachedImages(Event event, List<BlobData> blobs) async {
    var updatedImages = await EventAPI().uploadImages(event.hash, blobs);
    localUploadCachedImages(event, updatedImages);
  }

  Future<void> retrieveImageUpdatesByHash(Event event) async {
    var updatedImages =
        await EventAPI().retrieveImageUpdatesFromHash(event.hash);

    localImageUpdate(event, updatedImages);
  }

  void localDelete(Event event, {String? profileHash}) {
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

  Future<void> delete(Event event) async {
    await EventAPI().delete(event.hash);
    localDelete(event);
  }
}
