import 'package:wyd_front/API/Event/create_event_request_dto.dart';
import 'package:wyd_front/API/Event/update_event_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/model/event_details.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';
import 'package:wyd_front/state/event/event_provider.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class EventViewService {
  // TODO put this under a provider
  static void initialize(Event? initialEvent, DateTime? date, bool confirmed) {
    EventDetails? details;
    if (initialEvent != null) {
      EventRetrieveService.retrieveDetailsByHash(initialEvent.eventHash);

      details = EventDetailsProvider().get(initialEvent.eventHash);
    }
    EventViewProvider().initialize(initialEvent, date, confirmed, details);
  }

  static Future<Event> create(Event event) async {
    var createDto = CreateEventRequestDto.fromEvent(event);
    var createdEvent = await EventAPI().create(createDto);
    return EventRetrieveService.addEvent(createdEvent);
  }

  static Future<void> update(UpdateEventRequestDto updateDto) async {
    var eventDto = await EventAPI().update(updateDto);
    EventRetrieveService.addEvent(eventDto);
  }

  static void localConfirm(String eventHash, bool confirmed, {String? pHash}) {
    var event = EventProvider().findEventByHash(eventHash)!;
    String profileHash = pHash ?? UserProvider().getCurrentProfileHash();

    if (ProfileEventsProvider().confirm(eventHash, confirmed, profileHash)) {
      event.totalConfirmed += confirmed ? 1 : -1;
      EventViewProvider().updateCurrentEvent(event);
    }
  }

  static Future<void> confirm(String eventHash) async {
    await EventAPI().confirm(eventHash);

    localConfirm(eventHash, true);
  }

  static Future<void> decline(String eventHash) async {
    await EventAPI().decline(eventHash);

    localConfirm(eventHash, false);
  }

  static Future<void> shareToGroups(String eventHash, Set<int> groupsIds) async {
    var eventDto = await EventAPI().shareToProfiles(eventHash, groupsIds);
    EventRetrieveService.addEvent(eventDto);
  }

  static void localDelete(Event event, {String? profileHash}) {
    var pHash = profileHash ?? UserProvider().getCurrentProfileHash();
    event.removeProfile(pHash);

    if (event.countMatchingProfiles(UserProvider().getProfileHashes()) == 0) {
      EventViewProvider().close();

      ProfileEventsProvider().remove(event.eventHash);
      EventDetailsProvider().remove(event.eventHash);
      EventProvider().remove(event);
    }
  }

  static Future<void> delete(Event event) async {
    await EventAPI().delete(event.eventHash);
    localDelete(event);
  }
}
