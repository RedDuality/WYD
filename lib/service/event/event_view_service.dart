import 'package:wyd_front/API/Event/create_event_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/model/event_details.dart';
import 'package:wyd_front/service/event/event_service.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';

class EventViewService {
  // TODO put this under a provider
  static void initialize(Event? initialEvent, DateTime? date, bool confirmed) {
    EventDetails? details;
    if (initialEvent != null) {
      EventService.retrieveByHash(initialEvent.eventHash);

      details = EventDetailsProvider().get(initialEvent.eventHash);
    }
    EventViewProvider().initialize(initialEvent, date, confirmed, details);
  }

  static void localConfirm(Event event, bool confirmed, {String? profileHash}) {
    confirmed ? event.confirm(profHash: profileHash) : event.dismiss(profHash: profileHash);
    EventService.localUpdate(event);
  }

  static Future<Event> create(Event event) async {
    var createDto = CreateEventRequestDto.fromEvent(event);
    var createdEvent = await EventAPI().create(createDto);
    return EventService.addEvent(createdEvent);
  }

  static Future<void> update(Event updatedEvent) async {
    var eventDto = await EventAPI().update(updatedEvent);
    EventService.localUpdateFromDto(eventDto);
  }

  static Future<void> confirm(Event event) async {
    await EventAPI().confirm(event.eventHash);

    localConfirm(event, true);
  }

  static Future<void> decline(Event event) async {
    await EventAPI().decline(event.eventHash);

    localConfirm(event, false);
  }

  static Future<void> shareToGroups(String eventHash, Set<int> groupsIds) async {
    var eventDto = await EventAPI().shareToProfiles(eventHash, groupsIds);
    EventService.localUpdateFromDto(eventDto);
  }
}
