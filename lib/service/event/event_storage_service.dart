import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/event_details_cache.dart';
import 'package:wyd_front/state/event/event_intervals_cache.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_storage.dart';

class EventStorageService {
  static Future<void> _addEvents(
    List<RetrieveEventResponseDto> dtos,
    DateTimeRange dateRange,
  ) async {
    final events = await Future.wait(dtos.map(_deserializeEvent));

    await EventIntervalsCache().addInterval(dateRange);

    await EventStorage().saveMultiple(events, dateRange);
  }

  static Future<Event> addEvent(RetrieveEventResponseDto dto) async {
    var event = await _deserializeEvent(dto);
    await EventStorage().saveEvent(event);

    return event;
  }

  static Future<Event> _deserializeEvent(RetrieveEventResponseDto dto) async {
    if (dto.sharedWith != null) {
      await DetailedProfileEventsStorage().saveMultipleProfileEvents(dto.id, dto.sharedWith!);
    }

    if (dto.details != null) {
      EventDetailsCache().update(dto.id, dto.details!);
    }

    return Event.fromDto(dto);
  }

  //
  static Future<List<Event>> retrieveEventsInTimeRange(DateTimeRange requestedInterval) async {
    var missingInterval = EventIntervalsCache().getMissingInterval(requestedInterval);

    if (missingInterval != null) unawaited(_retrieveFromServer(missingInterval));

    return EventStorage().getEventsInRange(requestedInterval);
  }

  // for auto media retrieval
  static Future<List<Event>> retrieveEventsEndedIn(DateTimeRange requestedInterval) async {
    var missingInterval = EventIntervalsCache().getMissingInterval(requestedInterval);

    if (missingInterval != null) await _retrieveFromServer(missingInterval); // in this case we wait

    return EventStorage().getEventsEndingInRange(requestedInterval);
  }

  static Future<void> _retrieveFromServer(DateTimeRange retrieveInterval) async {
    var dtos = await EventRetrieveService.retrieveFromServer(retrieveInterval);
    await _addEvents(dtos, retrieveInterval);
  }
}
