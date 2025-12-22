import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_multiple_events_request_dto.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
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

  //real time update, another device(of the same user) created a new event
  static Future<void> retrieveEssentialByHash(String eventId) async {
    var eventDto = await EventAPI().retrieveEssentialsFromHash(eventId);
    EventStorageService.addEvent(eventDto);
  }

  static Future<void> checkAndRetrieveEssentialByHash(String eventId, DateTime updatedAt) async {
    var event = await EventStorage().getEventByHash(eventId);
    // in case I was the one that updated the event, it's not necessary to retrieve the event
    if (event == null || updatedAt.isAfter(event.updatedAt)) {
      retrieveEssentialByHash(eventId);
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
  static Future<Event> retrieveAndAddByHash(String eventId) async {
    var event = await EventStorage().getEventByHash(eventId);
    if (event == null) {
      var sharedEvent = await EventAPI().sharedWithHash(eventId);
      return EventStorageService.addEvent(sharedEvent);
    } else {
      //should already be updated
      return event;
    }
  }
}
