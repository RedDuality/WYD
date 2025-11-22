import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';
import 'package:wyd_front/state/util/event_intervals_cache_manager.dart';

class EventStorageService {
  static Future<void> _addEvents(
    List<RetrieveEventResponseDto> dtos,
    DateTimeRange dateRange,
  ) async {
    // Kick off all deserializations in parallel
    final events = await Future.wait(dtos.map(_deserializeEvent));

    // Ensure interval is cached before saving
    await EventIntervalsCacheManager().addInterval(dateRange);

    await EventStorage().saveMultiple(events, dateRange);
  }

  static Future<Event> addEvent(RetrieveEventResponseDto dto) async {
    var event = await _deserializeEvent(dto);
    await EventStorage().saveEvent(event);

    return event;
  }

  static Future<Event> _deserializeEvent(RetrieveEventResponseDto dto) async {
    if (dto.details != null) {
      EventDetailsStorage().update(dto.id, dto.details!);
    }

    if (dto.sharedWith != null) {
      await ProfileEventsStorage().saveMultiple(dto.id, dto.sharedWith!);
    }

    return Event.fromDto(dto);
  }

  static Future<List<Event>> retrieveEventsInTimeRange(DateTimeRange requestedInterval) async {
    var missingInterval = EventIntervalsCacheManager().getMissingInterval(requestedInterval);

    if (missingInterval != null) _retrieveFromServer(missingInterval);

    return EventStorage().getEventsInRange(requestedInterval);
  }

  static Future<List<Event>> retrieveEventsEndedIn(DateTimeRange requestedInterval) async {
    var missingInterval = EventIntervalsCacheManager().getMissingInterval(requestedInterval);

    if (missingInterval != null) await _retrieveFromServer(missingInterval); // here we wait

    return EventStorage().getEventsEndingInRange(requestedInterval);
  }

  static Future<void> _retrieveFromServer(DateTimeRange retrieveInterval) async {
    var dtos = await EventRetrieveService.retrieveFromServer(retrieveInterval);
    await _addEvents(dtos, retrieveInterval);
  }

  static Future<void> setHasCachedMedia(String eventHash, bool hasCachedMedia) async {
    var event = await EventStorage().getEventByHash(eventHash);
    event!.hasCachedMedia = hasCachedMedia;
    EventStorage().saveEvent(event);
  }
}
