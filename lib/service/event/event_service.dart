import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_multiple_events_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/model/event_details.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/service/event/event_details_service.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';
import 'package:wyd_front/state/event/event_provider.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class EventService {
  static void localUpdate(Event updatedEvent, {EventDetails? details, Set<ProfileEvent>? profileEvents}) {
    EventProvider().updateEvent(updatedEvent);

    if (details != null) {
      EventDetailsService.update(updatedEvent.eventHash, details);
    }

    EventViewProvider().updateCurrentEvent(updatedEvent);
  }

  static void localUpdateFromDto(RetrieveEventResponseDto eventDto) {
    var event = Event.fromDto(eventDto);
    var details = eventDto.details;
    localUpdate(event, details: details);
  }

  static void _addEvents(List<RetrieveEventResponseDto> dtos) {
    for (var dto in dtos) {
      addEvent(dto);
    }
  }

  static Event addEvent(RetrieveEventResponseDto dto) {
    var event = Event.fromDto(dto);
    if (dto.details != null) {
      EventDetailsService.updateFromFetched(event.eventHash, dto.details!);
    }

    if (dto.sharedWith != null) {
      ProfileEventsProvider().add(event.eventHash, dto.sharedWith!);
    }

    EventProvider().add(event);
    return event;
  }

  static Future<void> retrieveMultiple() async {
    // TODO make this better

    // Get the current date.
    final now = DateTime.now();

    // Calculate the start of the week (Monday at 00:00:00).
    final int daysToSubtract = now.weekday - 1 + 7;
    final startTime = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));

    // Calculate the end of the week (Sunday at 23:59:59).
    final int daysToAdd = 7 - now.weekday + 7;
    final endTime = DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysToAdd))
        .add(Duration(hours: 23, minutes: 59, seconds: 59));

    var retrieveDto = RetrieveMultipleEventsRequestDto(
        profileHashes: ProfilesProvider().getMyProfiles().map((profile) => profile.hash).toList(),
        startTime: startTime,
        endTime: endTime);

    var dtos = await EventAPI().listEvents(retrieveDto);
    _addEvents(dtos);
  }

  //details,
  // but also real time update, another device created a new event
  static Future<void> retrieveByHash(String eventHash) async {
    var event = await EventAPI().retrieveFromHash(eventHash);
    addEvent(event);
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
      var event = await EventAPI().retrieveFromHash(eventHash);
      addEvent(event);
    } else {
      retrieveUpdateByHash(eventHash);
    }
  }

  static Future<void> retrieveUpdateByHash(String eventHash) async {
    var eventDto = await EventAPI().retrieveFromHash(eventHash);
    localUpdateFromDto(eventDto);
  }

  static void localDelete(Event event, {String? profileHash}) {
    var pHash = profileHash ?? UserProvider().getCurrentProfileHash();
    event.removeProfile(pHash);

    if (event.countMatchingProfiles(UserProvider().getProfileHashes()) == 0) {
      EventViewProvider().close();

      ProfileEventsProvider().remove(event.eventHash);
      EventDetailsProvider().remove(event.eventHash);
      EventProvider().remove(event);
    } else {
      localUpdate(event);
    }
  }

  static Future<void> delete(Event event) async {
    await EventAPI().delete(event.eventHash);
    localDelete(event);
  }
}
