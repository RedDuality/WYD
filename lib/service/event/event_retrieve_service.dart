import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_multiple_events_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';
import 'package:wyd_front/state/event/event_provider.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';
import 'package:wyd_front/state/util/event_cache_manager.dart';

class EventRetrieveService {

  static void _addEvents(List<RetrieveEventResponseDto> dtos) {
    for (var dto in dtos) {
      addEvent(dto);
    }
  }

  static Event addEvent(RetrieveEventResponseDto dto) {
    var event = Event.fromDto(dto);
    EventProvider().addEvent(event);

    if (dto.details != null) {
      EventDetailsProvider().update(event.eventHash, dto.details!);
    }

    if (dto.sharedWith != null) {
      ProfileEventsProvider().add(event.eventHash, dto.sharedWith!);
    }
    // TODO remove this
    EventViewProvider().updateCurrentEvent(event);
    return event;
  }

  static Future<void> retrieveMultiple(DateTime startTime, DateTime endTime) async {
    var requestedInterval = DateTimeInterval(startTime, endTime);
    var retrieveInterval = EventCacheManager().getMissingInterval(requestedInterval);

    if (retrieveInterval != null) {
      var retrieveDto = RetrieveMultipleEventsRequestDto(
          profileHashes: ProfilesProvider().getMyProfiles().map((profile) => profile.id).toList(),
          startTime: retrieveInterval.start,
          endTime: retrieveInterval.end);

      var dtos = await EventAPI().listEvents(retrieveDto);
      _addEvents(dtos);
      EventCacheManager().addInterval(retrieveInterval);
    }
  }

  //real time update, another device(of the same user) created a new event
  static Future<void> retrieveEssentialByHash(String eventHash) async {
    var event = await EventAPI().retrieveEssentialsFromHash(eventHash);
    addEvent(event);
  }

  // getDetails(open event details/ updateDetails)
  static Future<void> retrieveDetailsByHash(String eventHash) async {
    var event = await EventAPI().retrieveDetailsFromHash(eventHash);
    addEvent(event);
  }

  static Future<void> retrieveUpdateByHash(String eventHash) async {
    var eventDto = await EventAPI().retrieveEssentialsFromHash(eventHash);
    addEvent(eventDto);
  }

  //someone shared a link, have to also add on the backend
  static Future<Event> retrieveAndAddByHash(String eventHash) async {
    var event = EventProvider().findEventByHash(eventHash);
    if (event == null) {
      var sharedEvent = await EventAPI().sharedWithHash(eventHash);
      return addEvent(sharedEvent);
    } else {
      //should already be updated
      return event;
    }
  }

  //someone shared an event with profileId
  static Future<void> retrieveSharedByHash(String eventHash) async {
    if (EventProvider().findEventByHash(eventHash) == null) {
      var event = await EventAPI().retrieveEssentialsFromHash(eventHash);
      addEvent(event);
    } else {
      retrieveUpdateByHash(eventHash);
    }
  }

}
