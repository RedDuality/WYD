import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wyd_front/API/Community/share_event_request_dto.dart';
import 'package:wyd_front/API/Event/create_event_request_dto.dart';
import 'package:wyd_front/API/Event/update_event_request_dto.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/event/event_details_cache.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/service/event/profile_events_storage_service.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_storage.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class EventActionsService {
  static Future<Event> createEvent(CreateEventRequestDto createDto) async {
    var createdEventDto = await EventAPI().create(createDto);

    var event = await EventStorageService.addEvent(createdEventDto);
    return event;
  }

  static Future<void> update(UpdateEventRequestDto updateDto) async {
    var eventDto = await EventAPI().update(updateDto);
    EventStorageService.addEvent(eventDto);
  }

  static Future<void> localConfirm(String eventId, bool confirmed, {String? pHash}) async {
    var event = await EventStorage().getEventById(eventId);
    if (event != null) {
      String profileId = pHash ?? UserCache().getCurrentProfileId();

      if (await ProfileEventsStorageService.confirm(eventId, confirmed, profileId)) {
        EventRetrieveService.retrieveEssentialByHash(eventId);

        if (UserCache().containsProfile(profileId)) {
          if (confirmed) {
            MaskService.retrieveEventMask(eventId);
          } else {
            MaskService.deleteEventMask(eventId);
          }
        }
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

  static Future<void> shareToGroups(String eventId, Set<ShareGroupIdentifierDto> groupsIds) async {
    var shareDto = ShareEventRequestDto(sharedGroups: groupsIds);
    var eventDto = await EventAPI().shareToProfiles(eventId, shareDto);
    EventStorageService.addEvent(eventDto);
  }

  static Future<void> send(Event originalEvent, BuildContext context) async {
    String? siteUrl = dotenv.env['SITE_URL'];
    String fullUrl = "$siteUrl/#/share?event=${originalEvent.id}";

    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: fullUrl));

      if (context.mounted) {
        InformationService().showInfoPopup(context, "Link copiato con successo");
      }
    } else {
      // If running on mobile, use the share dialog
      final result = await SharePlus.instance.share(ShareParams(text: fullUrl, subject: originalEvent.title));
      if (result == ShareResult.unavailable) {
        debugPrint("It was not possible to share the event");
      }
    }
  }

  static Future<void> delete(String eventId) async {
    Event? event = await EventStorage().getEventById(eventId);
    if (event != null) {
      await EventAPI().delete(event.id);
      localDelete(event);
    }
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
}
