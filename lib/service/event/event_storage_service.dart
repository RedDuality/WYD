import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_recurrent_event_response_dto.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/model/events/recurrent_event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/event_details_cache.dart';
import 'package:wyd_front/state/event/event_intervals_cache.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/event/recurrent_event_storage.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_storage.dart';

class EventStorageService {
  static Future<List<Event>> addEvents(
    List<RetrieveEventResponseDto> instanceDtos,
    List<RetrieveRecurrentEventResponseDto> masterDtos,
    DateTimeRange dateRange,
  ) async {
    final masters = await Future.wait(masterDtos.map(_deserializeRecurrentEvent));
    final events = await Future.wait(instanceDtos.map(_deserializeEvent));

    await EventStorage().saveMultiple(events);
    await RecurrentEventStorage().saveMultiple(masters);

    await EventIntervalsCache().addInterval(dateRange);
    return events;
  }

  // Assures that the detailed profile is updated, and that eventually the event will be saved
  static Future<Event> addEvent(RetrieveEventResponseDto dto) async {
    var event = await _deserializeEvent(dto);
    unawaited(EventStorage().saveEvent(event));

    return event;
  }

  static Future<Event> _deserializeEvent(RetrieveEventResponseDto dto) async {
    if (dto.sharedWith != null) {
      await DetailedProfileEventsStorage().saveMultipleProfileEvents(dto.id, dto.sharedWith!);
    }

    if (dto.details != null) {
      if (dto.masterEventId.isNotEmpty && dto.detachedInstance == false) {
        //generated, save the details on the masterId
        EventDetailsCache().update(dto.masterEventId, dto.details!);
      } else {
        EventDetailsCache().update(dto.id, dto.details!);
      }
    }

    return Event.fromDto(dto);
  }

  static Future<RecurrentEvent> _deserializeRecurrentEvent(RetrieveRecurrentEventResponseDto dto) async {
    if (dto.sharedWith != null) {
      await DetailedProfileEventsStorage().saveMultipleProfileEvents(dto.id, dto.sharedWith!);
    }

    if (dto.details != null) {
      EventDetailsCache().update(dto.id, dto.details!);
    }

    return RecurrentEvent.fromDto(dto);
  }

  // for images retrieval
  static Future<List<Event>> retrieveEventsEndedIn(DateTimeRange requestedInterval) async {
    var missingInterval = EventIntervalsCache().getMissingInterval(requestedInterval);

    if (missingInterval != null) await retrieveFromServer(missingInterval); // in this case we wait

    return EventStorage().getEventsEndingInRange(requestedInterval);
  }

  static Future<void> retrieveFromServer(DateTimeRange retrieveInterval) async {
    var responseDto = await EventRetrieveService.retrieveFromServer(retrieveInterval);
    await addEvents(responseDto.events, responseDto.masters, retrieveInterval);
  }
}
