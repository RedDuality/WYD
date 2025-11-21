import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';
import 'package:wyd_front/state/util/event_intervals_cache_manager.dart';

class EventStorageService {
  static Future<void> addEvents(
    List<RetrieveEventResponseDto> dtos,
    DateTimeRange dateRange,
  ) async {
    // Kick off all deserializations in parallel
    final events = await Future.wait(dtos.map(_deserializeEvent));

    // Ensure interval is cached before saving
    await EventIntervalsCacheManager().addInterval(dateRange);

    // Save all events once deserialization is complete
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

    // this goes before to allow event.currentConfirmed
    if (dto.sharedWith != null) {
      await ProfileEventsStorage().saveMultiple(dto.id, dto.sharedWith!);
    }

    return Event.fromDto(dto);
  }

  static Future<List<Event>> retrieveEventsInTimeRange(DateTimeRange requestedInterval) async {
    var missingInterval = EventIntervalsCacheManager().getMissingInterval(requestedInterval);

    if (missingInterval != null) {
      EventRetrieveService.retrieveFromServer(missingInterval).then((dtos) {
        addEvents(dtos, missingInterval);
      });
    }

    return EventStorage().getEventsInTimeRange(requestedInterval);
  }

  static Future<void> setHasCachedMedia(String eventHash, bool hasCachedMedia) async {
    var event = await EventStorage().getEventByHash(eventHash);
    event!.hasCachedMedia = hasCachedMedia;
    EventStorage().saveEvent(event);
  }

  Future<List<Event>> getEventsToShowInRange(
    DateTime date,
  ) async {
    return [];
  }
}
