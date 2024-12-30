import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/event_api.dart';
import 'package:wyd_front/API/user_api.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/blob_provider.dart';
import 'package:wyd_front/state/detail_provider.dart';
import 'package:wyd_front/state/event_provider.dart';

class EventService {
  Future<void> retrieveShootedPhotos(String eventHash) async {
    var event = EventProvider().findEventByHash(eventHash);
    if (event != null) {
      var photosDuringEvent = await ImageService().retrieveImagesByTime(
          event.startTime!.toUtc(), event.endTime!.toUtc());
      if (photosDuringEvent.isNotEmpty) {
        event.cachedNewImages = photosDuringEvent;
        addCachedImages(event);
      }
    }
  }

  void initializeDetails(Event? initialEvent, DateTime? date, bool confirmed) {
    DetailProvider().initialize(initialEvent, date, confirmed);
    BlobProvider().initialize(
        hash: initialEvent?.hash,
        cachedImages: initialEvent?.cachedNewImages,
        imageHashes: initialEvent?.images);
  }

  void addCachedImages(Event event) {
    EventProvider().updateEvent(event);
    BlobProvider().addCachedImages(event);
  }

  void localUpdate(Event updatedEvent) {
    EventProvider().updateEvent(updatedEvent);
    DetailProvider().updateCurrentEvent(updatedEvent);
  }

  void localImageUpdate(Event updatedEvent) {
    EventProvider().updateEvent(updatedEvent);
    BlobProvider().updateImageHashes(updatedEvent.images);
  }

  void localConfirm(Event event, bool confirmed, {String? profileHash}) {
    event.confirm(confirmed, profHash: profileHash);
    localUpdate(event);
  }

  Future<void> retrieveMultiple() async {
    var events = await UserAPI().listEvents();

    EventProvider().addAll(events);
  }

  Future<void> retrieveUpdateByHash(String eventHash) async {
    var event = await EventAPI().retrieveFromHash(eventHash);

    localUpdate(event);
  }

  Future<void> retrieveImageUpdateByHash(String eventHash) async {
    var event = await EventAPI().retrieveFromHash(eventHash);

    localImageUpdate(event);
  }

  Future<void> retrieveSharedByHash(String eventHash) async {
    if (EventProvider().findEventByHash(eventHash) == null) {
      var event = await EventAPI().retrieveFromHash(eventHash);
      EventProvider().add(event);
    }
  }

  Future<void> retrieveNewByHash(String eventHash) async {
    var event = await EventAPI().retrieveFromHash(eventHash);

    EventProvider().add(event);
  }

  Future<Event> retrieveAndAddByHash(String eventHash) async {
    var event = await EventAPI().sharedWithHash(eventHash);

    EventProvider().add(event);
    return event;
  }

  Future<Event> create(Event event) async {
    var createdEvent = await EventAPI().create(event);
    EventProvider().add(createdEvent);
    return createdEvent;
  }

  Future<void> update(Event updatedEvent) async {
    var event = await EventAPI().update(updatedEvent);

    localUpdate(event);
  }

  Future<void> uploadImages(String eventHash, List<BlobData> blobs) async {
    var event = await EventAPI().uploadImages(eventHash, blobs);

    localImageUpdate(event);
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
}
