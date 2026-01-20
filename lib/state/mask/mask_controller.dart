import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:wyd_front/API/Mask/update_mask_request_dto.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';

/// Instead of storing Mask objects in CalendarEvent, we store only the mask ID
class MaskController extends DefaultEventsController<String> {
  /// Maps mask.id (String) to calendar event id (int)
  final Map<String, int> _maskIdToEventId = {};

  final MaskCache _maskCache;

  MaskController(this._maskCache);

  void updateWithMasks() {
    final masks = _maskCache.allMasks;
    final maskIds = <String>{};

    for (final mask in masks) {
      maskIds.add(mask.id);
      final newEvent = _calndEventFromMask(mask);
      final existingEventId = _maskIdToEventId[mask.id];

      if (existingEventId != null) {
        // update
        final existingEvent = byId(existingEventId);

        if (existingEvent != null) {
          if (_hasChanged(existingEvent, newEvent)) {
            // this also prevents infinite requests as updateEvent -> server -> maskcache -> updateWithMasks
            updateEvent(event: existingEvent, updatedEvent: newEvent);
          }
        }
      } else {
        // New mask, create event for it (only stores the ID string)
        final eventId = addEvent(newEvent);
        _maskIdToEventId[mask.id] = eventId;
      }
    }

    // Remove events for masks that no longer exist
    final toRemove = _maskIdToEventId.keys.where((id) => !maskIds.contains(id)).toList();
    for (final maskId in toRemove) {
      final eventId = _maskIdToEventId[maskId]!;
      final event = byId(eventId);
      if (event != null) {
        removeEvent(event);
      }
      _maskIdToEventId.remove(maskId);
    }
  }

  CalendarEvent<String> _calndEventFromMask(Mask mask) {
    return CalendarEvent<String>(
      data: mask.id,
      dateTimeRange: DateTimeRange(
        start: mask.startTime,
        end: mask.endTime,
      ),
    );
  }

  bool _hasChanged(CalendarEvent<String> oldEvent, CalendarEvent<String> newEvent) {
    // The ID is the same (we're only updating if the ID matches)
    // But the date/time might have changed
    return oldEvent.dateTimeRange != newEvent.dateTimeRange;
  }

  @override
  void updateEvent({
    required CalendarEvent<String> event,
    required CalendarEvent<String> updatedEvent,
  }) {
    updatedEvent.id = event.id;
    var mask = _maskCache.findById(event.data!);

    if (mask.eventId != null && mask.eventId!.isNotEmpty) {
      debugPrint( "Cannot modify a preview related to an Event");
      return;
    }

    final updateDto = UpdateMaskRequestDto(
      maskId: mask.id.toString(),
      title: mask.title,
      startTime: updatedEvent.dateTimeRange.start,
      endTime: updatedEvent.dateTimeRange.end,
    );

    dateMap.updateEvent(event, updatedEvent);
    notifyListeners();

    unawaited(MaskService.update(updateDto));
  }
}
