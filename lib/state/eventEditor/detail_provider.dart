import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/user_provider.dart';

const int titleMod = 1;
const int descriptionMod = 2;
const int datesMod = 4;

class DetailProvider extends ChangeNotifier {
  // Private static instance variable
  static final DetailProvider _instance = DetailProvider._internal();

  // Private constructor
  DetailProvider._internal();

  // Public factory method to provide access to the instance
  factory DetailProvider() {
    return _instance;
  }

  Event? originalEvent;

  String? hash;

  String title = "Evento senza nome";
  String? description;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(hours: 1));

  bool confirmed = false;
  List<ProfileEvent> sharedWith = [];

  int changes = 0;

  void initialize(Event? initialEvent, DateTime? date, bool confirmed) {
    originalEvent = initialEvent;
    hash = initialEvent?.hash;

    title = initialEvent?.title ?? "Evento senza nome";
    description = initialEvent?.description;

    startTime = initialEvent?.startTime ?? (date ?? DateTime.now());
    endTime = initialEvent?.endTime ??
        (date ?? DateTime.now()).add(const Duration(hours: 1));

    this.confirmed = initialEvent?.confirmed() ?? confirmed;

    if (initialEvent == null) {
      String mainProfileHash = UserProvider().getCurrentProfileHash();
      ProfileEvent profileEvent =
          ProfileEvent(mainProfileHash, EventRole.owner, confirmed, true);
      sharedWith.add(profileEvent);
    } else {
      sharedWith = initialEvent.sharedWith;
    }

    changes = 0;

    notifyListeners();
  }

  void updateCurrentEvent(Event newEvent) {
    if (hash == newEvent.hash) {
      originalEvent = newEvent;
      startTime = newEvent.startTime!;
      endTime = newEvent.endTime!;

      title = newEvent.title;
      description = newEvent.description;

      confirmed = newEvent.confirmed();

      sharedWith = newEvent.sharedWith;

      changes = 0;

      notifyListeners();
    }
  }

  void close() {
    hash = "";
  }

  bool exists() {
    return originalEvent != null;
  }

  bool hasBeenChanged() {
    return changes != 0;
  }

  bool isOwner() {
    return originalEvent!.isOwner();
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
      }
    }
  }

  void updateTitle(String newTitle) {
    title = newTitle;
    _updateType(titleMod);
    notifyListeners();
  }

  void updateDescription(String newDescription) {
    description = newDescription;

    _updateType(descriptionMod);
    notifyListeners();
  }

  void updateDates(DateTime start, DateTime end) {
    startTime = start;
    endTime = end;
    _updateType(datesMod);
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
      sharedWith: sharedWith,
    );

    return event;
  }
}
