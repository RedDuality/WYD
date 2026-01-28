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
  final Map<String, int> _maskIdToEventIdMap = {};

  final MaskCache? _maskCache;

  MaskController(this._maskCache);

  void updateWithMasks(Set<Mask> masks) {
    final incomingMaskIds = masks.map((m) => m.id).toSet();

    _removeFromView(incomingMaskIds);

    for (final mask in masks) {
      _addOrUpdate(mask);
    }

    notifyListeners();
  }

  void _removeFromView(Set<String> incomingMaskIds) {
    _maskIdToEventIdMap.removeWhere((maskId, eventId) {
      final hasBeenDeleted = !incomingMaskIds.contains(maskId);
      if (hasBeenDeleted) {
        final event = byId(eventId);
        if (event != null) dateMap.removeEvent(event); // remove from view
      }
      return hasBeenDeleted; // remove from map
    });
  }

  void _addOrUpdate(Mask mask) {
    final newCalendarEvent = _calndEventFromMask(mask);
    final oldCalendarEventId = _maskIdToEventIdMap[mask.id];

    if (oldCalendarEventId != null) {
      // currently in view

      final existingEvent = byId(oldCalendarEventId);

      if (existingEvent != null && _hasChanged(existingEvent, newCalendarEvent)) {
        newCalendarEvent.id = existingEvent.id;
        dateMap.updateEvent(existingEvent, newCalendarEvent);
      }
    } else {
      final eventId = dateMap.addNewEvent(newCalendarEvent);
      _maskIdToEventIdMap[mask.id] = eventId;
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
    if (_maskCache == null) throw "You are trying to update events of another profile!";

    var mask = _maskCache.findById(event.data!);

    if (mask.eventId != null && mask.eventId!.isNotEmpty) {
      debugPrint("Cannot modify a preview related to an Event");
      return;
    }

    final updateDto = UpdateMaskRequestDto(
      maskId: mask.id.toString(),
      title: mask.title,
      startTime: updatedEvent.dateTimeRange.start,
      endTime: updatedEvent.dateTimeRange.end,
    );

    //dateMap.updateEvent(event, updatedEvent);
    unawaited(MaskService.update(updateDto));
  }
}
