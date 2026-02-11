import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_multiple_events_request_dto.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/service/event/profile_events_storage_service.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class EventRetrieveService {
  static Future<List<RetrieveEventResponseDto>> retrieveFromServer(DateTimeRange retrieveInterval) async {
    var retrieveDto = RetrieveMultipleEventsRequestDto(
        profileIds: UserCache().getProfileIds(),
        startTime: retrieveInterval.start.toUtc(),
        endTime: retrieveInterval.end.toUtc());

    return await EventAPI().listEvents(retrieveDto);
  }

  static Future<Event> retrieveEssentialByHash(String eventId) async {
    var eventDto = await EventAPI().retrieveEssentialsFromHash(eventId);
    return await EventStorageService.addEvent(eventDto);
  }

  //real time update
  static Future<void> checkAndRetrieveEssentialByHash(String eventId, DateTime updatedAt, String? actorId) async {
    debugPrint("eventId $eventId");
    var event = await EventStorage().getEventById(eventId);
    debugPrint("event null: ${(event == null).toString()}");
    if (event == null || updatedAt.isAfter(event.updatedAt)) {
      await retrieveEssentialByHash(eventId);
    }
    //create or update
    // TODO check this
    if (actorId != null && UserCache().getProfileIds().contains(actorId)) {
      final confirmed = await ProfileEventsStorageService.hasProfileConfirmed(eventId, actorId);
      if (confirmed) {
        MaskService.retrieveEventMask(eventId);
      }
    }
  }

  // getDetails(open event details/ updateDetails)
  static Future<void> retrieveDetailsByHash(String eventId) async {
    var event = await EventAPI().retrieveDetailsFromHash(eventId);
    EventStorageService.addEvent(event);
  }

  static Future<void> checkEventUpdatesAfter(DateTime lastCheckedTime) async {
    var retrieveDto = RetrieveMultipleEventsRequestDto(
      profileIds: UserCache().getProfileIds(),
      startTime: lastCheckedTime,
    );

    var updatedEvents = await EventAPI().retrieveUpdatedAfter(retrieveDto);
    for (var eventDto in updatedEvents) {
      EventStorageService.addEvent(eventDto);
    }
  }

  //someone shared a link, have to also add on the backend
  static Future<Event> retrieveAndCreateSharedEvent(String eventId) async {
    var event = await EventStorage().getEventById(eventId);
    if (event == null) {
      var sharedEvent = await EventAPI().sharedWithHash(eventId);
      return EventStorageService.addEvent(sharedEvent);
    } else {
      //should already be updated
      return event;
    }
  }
}
