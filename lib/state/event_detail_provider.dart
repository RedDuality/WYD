import 'package:flutter/material.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/user_provider.dart';

const int titleMod = 1;
const int descriptionMod = 2;
const int datesMod = 4;
const int imagesMod = 8;

class EventDetailProvider extends ChangeNotifier {
  EventDetailProvider();

  Event? originalEvent;

  String? hash;

  String title = "Evento senza nome";
  String? description;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(hours: 1));

  bool confirmed = false;

  int changes = 0;

  List<String> imageHashes = [];

  final List<BlobData> newImages = [];

  void initialize(Event? initialEvent, DateTime? date, bool confirmed) {
    originalEvent = initialEvent;
    hash = initialEvent?.hash;

    title = initialEvent?.title ?? "Evento senza nome";
    description = initialEvent?.description;

    startTime = initialEvent?.startTime ?? (date ?? DateTime.now());
    endTime = initialEvent?.endTime ??
        (date ?? DateTime.now()).add(const Duration(hours: 1));

    this.confirmed = initialEvent?.confirmed() ?? confirmed;

    imageHashes = initialEvent?.images ?? [];

    notifyListeners();
  }

  bool exists() {
    return originalEvent != null;
  }

  bool hasBeenChanged() {
    return changes != 0;
  }

  void _updateType(int mod) {
    //updates type of modified field
    if (changes & mod == 0) {
      //first time modified
      changes = changes ^ mod;
    }
    //if returns to the original, uncheck that update type
    if (originalEvent != null) {
      switch (mod) {
        case titleMod:
          if (originalEvent!.title == title) {
            changes = changes - mod;
          }
          break;
        case descriptionMod:
          if (originalEvent!.description == description) {
            changes = changes - mod;
          }
          break;
        case datesMod:
          if (originalEvent!.startTime == startTime &&
              originalEvent!.endTime == endTime) {
            changes = changes - mod;
          }
          break;
        case imagesMod:
          if (newImages.isEmpty) {
            changes = changes - mod;
          }
          break;
      }
    }
  }

  void updateTitle(String newTitle) {
    title = newTitle;
    _updateType(titleMod);
    notifyListeners();
  }

  void updateDescription(String newDescription) {
    title = newDescription;

    _updateType(descriptionMod);
    notifyListeners();
  }

  void updateDates(DateTime start, DateTime end) {
    startTime = start;
    endTime = end;
    _updateType(datesMod);
    notifyListeners();
  }

  // Method to add a new image to the newImages list
  void addNewImage(BlobData image) {
    newImages.add(image);
    _updateType(imagesMod);
    notifyListeners();
  }

  void addNewImages(List<BlobData> images) {
    newImages.addAll(images);
    _updateType(imagesMod);
    notifyListeners();
  }

  void cleadNewImages() {
    newImages.clear();
    _updateType(imagesMod);
    notifyListeners();
  }

  void confirm() {
    confirmed = true;
    notifyListeners();
  }

  void decline() {
    confirmed = false;
    notifyListeners();
  }

  void updateEvent(Event newEvent) {
    originalEvent = newEvent;
    hash = newEvent.hash;

    startTime = newEvent.startTime!;
    endTime = newEvent.endTime!;

    title = newEvent.title;
    description = newEvent.description;

    confirmed = newEvent.confirmed();

    imageHashes = newEvent.images;

    changes = 0;

    notifyListeners();
  }

  Event getEventWithCurrentFields() {
    Event event = Event(
      hash: hash ?? "",
      date: startTime,
      startTime: startTime,
      endTime: endTime,
      endDate: endTime,
      title: title,
      description: description,
      images: imageHashes,
      newBlobs: newImages,
    );

    int mainProfileId = UserProvider().getCurrentProfileId();
    ProfileEvent profileEvent =
        ProfileEvent(mainProfileId, EventRole.owner, confirmed, true);
    event.sharedWith.add(profileEvent);

    return event;
  }
}
