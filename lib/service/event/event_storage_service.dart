import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/state/util/event_intervals_cache_manager.dart';

class EventStorageService {
  static Future<void> addEvents(List<RetrieveEventResponseDto> dtos, DateTimeRange dateRange) async {
    // first update the storage
    var events = dtos.map(Event.fromDto).toList();
        // update the loaded interval cache
    await EventIntervalsCacheManager().addInterval(dateRange);

    await EventStorage().saveMultiple(events, dateRange);

    // then details and profileEvents

    for (var dto in dtos) {
      if (dto.details != null) {
        EventDetailsStorage().update(dto.hash, dto.details!);
      }

      if (dto.sharedWith != null) {
        ProfileEventsProvider().add(dto.hash, dto.sharedWith!);
      }
    }


  }

  static Event addEvent(RetrieveEventResponseDto dto) {
    var event = Event.fromDto(dto);
    EventStorage().saveEvent(event);

    if (dto.details != null) {
      EventDetailsStorage().update(event.eventHash, dto.details!);
    }

    if (dto.sharedWith != null) {
      ProfileEventsProvider().add(event.eventHash, dto.sharedWith!);
    }

    return event;
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
}
