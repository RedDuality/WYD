import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';
import 'package:wyd_front/state/util/event_intervals_cache_manager.dart';

class EventStorageService {
  static void addEvents(List<RetrieveEventResponseDto> dtos, DateTimeRange dateRange) {
    // first update the storage
    var events = dtos.map(Event.fromDto).toList();
    EventStorage().saveMultiple(events, dateRange);

    // then details and profileEvents

    for (var dto in dtos) {
      if (dto.details != null) {
        EventDetailsProvider().update(dto.hash, dto.details!);
      }

      if (dto.sharedWith != null) {
        ProfileEventsProvider().add(dto.hash, dto.sharedWith!);
      }
    }

    // update the loaded interval cache
    EventIntervalsCacheManager().addInterval(dateRange);
  }

  static Event addEvent(RetrieveEventResponseDto dto) {
    var event = Event.fromDto(dto);
    EventStorage().saveEvent(event);

    if (dto.details != null) {
      EventDetailsProvider().update(event.eventHash, dto.details!);
    }

    if (dto.sharedWith != null) {
      ProfileEventsProvider().add(event.eventHash, dto.sharedWith!);
    }
    // TODO remove this, making the view listen to the provider
    EventViewProvider().updateCurrentEvent(event);
    return event;
  }

/*
  void addEvent(Event event) {
    var originalEvent = findEventByHash(event.eventHash);

    if (originalEvent != null && event.updatedAt.isAfter(originalEvent.updatedAt)) {
      if (originalEvent.endTime != event.endTime) {
        MediaAutoSelectService.addTimer(event);
      }
      super.update(originalEvent, event);
    } else {
      MediaAutoSelectService.addTimer(event);
      super.add(event);
    }
  }
  */
  static Future<List<Event>> getEventsInTimeRange(DateTimeRange requestedInterval) async {
    var retrieveInterval = EventIntervalsCacheManager().getMissingInterval(requestedInterval);

    if (retrieveInterval != null) {
      EventRetrieveService.retrieveFromServer(retrieveInterval).then((dtos) {
        debugPrint("retrievedEvents");
        addEvents(dtos, retrieveInterval);
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
