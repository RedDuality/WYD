import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_multiple_events_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/trash/calendar_view_event_controller.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';

class EventRetrieveService {

  static Future<List<RetrieveEventResponseDto>> retrieveFromServer(DateTimeRange retrieveInterval) async {
    var retrieveDto = RetrieveMultipleEventsRequestDto(
        profileHashes: ProfilesProvider().getMyProfiles().map((profile) => profile.id).toList(),
        startTime: retrieveInterval.start,
        endTime: retrieveInterval.end);

    var dtos = await EventAPI().listEvents(retrieveDto);
    return dtos;
  }

  //real time update, another device(of the same user) created a new event
  static Future<void> retrieveEssentialByHash(String eventHash) async {
    var event = await EventAPI().retrieveEssentialsFromHash(eventHash);
    EventStorageService.addEvent(event);
  }

  // getDetails(open event details/ updateDetails)
  static Future<void> retrieveDetailsByHash(String eventHash) async {
    var event = await EventAPI().retrieveDetailsFromHash(eventHash);
    EventStorageService.addEvent(event);
  }

  static Future<void> retrieveUpdateByHash(String eventHash) async {
    var eventDto = await EventAPI().retrieveEssentialsFromHash(eventHash);
    EventStorageService.addEvent(eventDto);
  }

  //someone shared a link, have to also add on the backend
  static Future<Event> retrieveAndAddByHash(String eventHash) async {
    var event = CalendarViewEventController().findEventByHash(eventHash);
    if (event == null) {
      var sharedEvent = await EventAPI().sharedWithHash(eventHash);
      return EventStorageService.addEvent(sharedEvent);
    } else {
      //should already be updated
      return event;
    }
  }

  //someone shared an event with profileId
  static Future<void> retrieveSharedByHash(String eventHash) async {
    if (CalendarViewEventController().findEventByHash(eventHash) == null) {
      var event = await EventAPI().retrieveEssentialsFromHash(eventHash);
      EventStorageService.addEvent(event);
    } else {
      retrieveUpdateByHash(eventHash);
    }
  }
}
