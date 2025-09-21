import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/update_event_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/event_details.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';

const int titleMod = 1;
const int descriptionMod = 2;
const int datesMod = 4;

class EventViewProvider extends ChangeNotifier {
  // Private static instance variable
  static final EventViewProvider _instance = EventViewProvider._internal();

  // Private constructor
  EventViewProvider._internal();

  // Public factory method to provide access to the instance
  factory EventViewProvider() {
    return _instance;
  }

  Event? originalEvent;

  String? hash;

  String title = "Evento senza nome";
  String? description;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(hours: 1));
  int totalConfirmed = 1;
  int totalProfiles = 1;

  bool confirmed = false;

  int changes = 0;

  void initialize(Event? initialEvent, DateTime? date, bool confirmed, EventDetails? details) {
    originalEvent = initialEvent;
    hash = initialEvent?.eventHash;

    title = initialEvent?.title ?? "Evento senza nome";
    description = details?.description;

    startTime = initialEvent?.startTime ?? (date ?? DateTime.now());
    endTime = initialEvent?.endTime ?? (date ?? DateTime.now()).add(const Duration(hours: 1));

    this.confirmed = initialEvent?.currentConfirmed() ?? confirmed;

    totalConfirmed = initialEvent?.totalConfirmed ?? 1;
    totalProfiles = initialEvent?.totalProfiles ?? 1;

    changes = 0;

    notifyListeners();
  }

  void updateCurrentEvent(Event newEvent) {
    if (hash == newEvent.eventHash) {
      originalEvent = newEvent;
      startTime = newEvent.startTime!;
      endTime = newEvent.endTime!;

      title = newEvent.title;

      description = EventDetailsProvider().get(newEvent.eventHash)?.description;

      confirmed = newEvent.currentConfirmed();

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
          if (originalEvent!.startTime == startTime && originalEvent!.endTime == endTime) {
            changes = changes - mod;
          }
          break;
      }
    }
  }

  void updateTitle(String newTitle, {bool finished = false}) {
    if (finished && newTitle.isEmpty) {
      title = originalEvent!.title;
    } else {
      title = newTitle;
    }
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
        eventHash: hash ?? "",
        date: startTime,
        startTime: startTime,
        endTime: endTime,
        endDate: endTime,
        updatedAt: DateTime.now(),
        title: title,
        description: description,
        totalConfirmed: totalConfirmed,
        totalProfiles: totalProfiles);

    return event;
  }

  UpdateEventRequestDto? getUpdateDto() {
    if (!hasBeenChanged()) return null;
    UpdateEventRequestDto updateDto = UpdateEventRequestDto(
      eventHash: hash!,
      title: title != originalEvent!.title ? title : null,
      description: description != originalEvent!.description ? description : null,
      startTime: startTime != originalEvent!.startTime ? startTime : null,
      endTime: endTime != originalEvent!.endTime ? endTime : null,
    );
    return updateDto;
  }
}
