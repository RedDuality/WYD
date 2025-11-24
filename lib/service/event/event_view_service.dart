import 'dart:async';

import 'package:wyd_front/API/Community/share_event_request_dto.dart';
import 'package:wyd_front/API/Event/create_event_request_dto.dart';
import 'package:wyd_front/API/Event/update_event_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/service/event/profile_events_storage_service.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class EventViewService {
  static final _profileColorChangeController = StreamController<void>();

  static Stream<void> get onProfileColorChangedStream => _profileColorChangeController.stream;

  static void notifyProfileColorChanged() {
    if (_profileColorChangeController.hasListener) {
      _profileColorChangeController.add(null);
    }
  }

  static void dispose() {
    _profileColorChangeController.close();
  }

  static Future<Event> create(Event event) async {
    var createDto = CreateEventRequestDto.fromEvent(event);
    var createdEvent = await EventAPI().create(createDto);
    return EventStorageService.addEvent(createdEvent);
  }

  static Future<void> update(UpdateEventRequestDto updateDto) async {
    var eventDto = await EventAPI().update(updateDto);
    EventStorageService.addEvent(eventDto);
  }

  static Future<void> localConfirm(String eventHash, bool confirmed, {String? pHash}) async {
    var event = await EventStorage().getEventByHash(eventHash);
    if (event != null) {
      String profileHash = pHash ?? UserCache().getCurrentProfileId();

      if (await ProfileEventsStorageService.confirm(eventHash, confirmed, profileHash)) {
        EventRetrieveService.retrieveEssentialByHash(eventHash);
      }
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

  static Future<void> shareToGroups(String eventHash, Set<ShareEventRequestDto> groupsIds) async {
    var eventDto = await EventAPI().shareToProfiles(eventHash, groupsIds);
    EventStorageService.addEvent(eventDto);
  }

  static Future<void> localDelete(Event event, {String? profileHash}) async {
    var pHash = profileHash ?? UserCache().getCurrentProfileId();
    await ProfileEventsStorage().removeSingle(event.id, pHash);

    var myProfileIds = UserCache().getProfileIds();
    var profilesOfEvent = await ProfileEventsStorage().countMatchingProfiles(event.id, myProfileIds);

    if (profilesOfEvent == 0) {
      ProfileEventsStorage().removeAll(event.id);
      EventDetailsStorage().remove(event.id);
      EventStorage().remove(event);
    }
  }

  static Future<void> delete(String eventHash) async {
    Event? event = await EventStorage().getEventByHash(eventHash);
    if (event != null) {
      await EventAPI().delete(event.id);
      localDelete(event);
    }
  }
}
