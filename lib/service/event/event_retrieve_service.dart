import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_multiple_events_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class EventRetrieveService {

  static Future<List<RetrieveEventResponseDto>> retrieveFromServer(DateTimeRange retrieveInterval) async {
    var retrieveDto = RetrieveMultipleEventsRequestDto(
        profileHashes: UserProvider().getProfileHashes(),
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

  static Future<void> checkAndRetrieveEssentialByHash(String eventHash, DateTime updatedAt) async {
    var event = await EventStorage().getEventByHash(eventHash);
    // in case I was the one that updated the event, it's not necessary to retrieve the event
    if (event == null || updatedAt.isAfter(event.updatedAt)) {
      retrieveEssentialByHash(eventHash);
    }
  }

  // getDetails(open event details/ updateDetails)
  static Future<void> retrieveDetailsByHash(String eventHash) async {
    var event = await EventAPI().retrieveDetailsFromHash(eventHash);
    EventStorageService.addEvent(event);
  }


  //someone shared a link, have to also add on the backend
  static Future<Event> retrieveAndAddByHash(String eventHash) async {
    var event = await EventStorage().getEventByHash(eventHash);
    if (event == null) {
      var sharedEvent = await EventAPI().sharedWithHash(eventHash);
      return EventStorageService.addEvent(sharedEvent);
    } else {
      //should already be updated
      return event;
    }
  }


}
