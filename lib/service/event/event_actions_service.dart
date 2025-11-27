import 'dart:async';

import 'package:wyd_front/API/Community/share_event_request_dto.dart';
import 'package:wyd_front/API/Event/create_event_request_dto.dart';
import 'package:wyd_front/API/Event/update_event_request_dto.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/event/event_details_cache.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/service/event/profile_events_storage_service.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_storage.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class EventActionsService {
  static final _profileColorChangeController = StreamController<void>.broadcast();

  static Stream<void> get onProfileColorChangedStream => _profileColorChangeController.stream;

  static void notifyProfileColorChanged() {
    if (_profileColorChangeController.hasListener) {
      _profileColorChangeController.add(null);
    }
  }

  static void dispose() {
    _profileColorChangeController.close();
  }

  static Future<String> create(CreateEventRequestDto createDto) async {
    var createdEventDto = await EventAPI().create(createDto);
    EventStorageService.addEvent(createdEventDto);
    return createdEventDto.id;
  }

  static Future<void> update(UpdateEventRequestDto updateDto) async {
    var eventDto = await EventAPI().update(updateDto);
    EventStorageService.addEvent(eventDto);
  }

  static Future<void> localConfirm(String eventId, bool confirmed, {String? pHash}) async {
    var event = await EventStorage().getEventByHash(eventId);
    if (event != null) {
      String profileHash = pHash ?? UserCache().getCurrentProfileId();

      if (await ProfileEventsStorageService.confirm(eventId, confirmed, profileHash)) {
        EventRetrieveService.retrieveEssentialByHash(eventId);
      }
    }
  }

  static Future<void> confirm(String eventId) async {
    await EventAPI().confirm(eventId);

    localConfirm(eventId, true);
  }

  static Future<void> decline(String eventId) async {
    await EventAPI().decline(eventId);

    localConfirm(eventId, false);
  }

  static Future<void> shareToGroups(String eventId, Set<ShareEventRequestDto> groupsIds) async {
    var eventDto = await EventAPI().shareToProfiles(eventId, groupsIds);
    EventStorageService.addEvent(eventDto);
  }

  static Future<void> localDelete(Event event, {String? profileHash}) async {
    var pHash = profileHash ?? UserCache().getCurrentProfileId();
    await DetailedProfileEventsStorage().removeSingle(event.id, pHash);

    var myProfileIds = UserCache().getProfileIds();
    var profilesOfEvent = await DetailedProfileEventsStorage().countMatchingProfiles(event.id, myProfileIds);

    if (profilesOfEvent == 0) {
      DetailedProfileEventsStorage().removeAll(event.id);
      EventDetailsCache().remove(event.id);
      EventStorage().remove(event);
    }
  }

  static Future<void> delete(String eventId) async {
    Event? event = await EventStorage().getEventByHash(eventId);
    if (event != null) {
      await EventAPI().delete(event.id);
      localDelete(event);
    }
  }
}
