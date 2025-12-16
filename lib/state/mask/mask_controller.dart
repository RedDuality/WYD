import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:wyd_front/model/mask/mask.dart';

/// Custom EventsController for managing Mask objects in Kalender.  
/// Keeps calendar events in sync with masks from your MaskCache WITHOUT copying data.
/// 
/// Instead of storing Mask objects in CalendarEvent, we store only the mask ID
/// and look it up from the cache on-demand.  This avoids expensive copying.
class MaskController extends DefaultEventsController<String> {
  /// Maps mask. id (String) to calendar event id (int)
  final Map<String, int> _maskIdToEventId = {};

  /// Sync masks from the cache with calendar events.  
  /// Call this whenever your MaskCache updates. 
  /// 
  /// This is O(n) where n is the number of new/updated masks, NOT all masks.
  void updateWithMasks(Iterable<Mask> masks) {
    final maskIds = <String>{};

    // Add or update events for each mask
    for (final mask in masks) {
      maskIds.add(mask.id);
      final newEvent = _maskToCalendarEvent(mask);
      final existingEventId = _maskIdToEventId[mask.id];

      if (existingEventId != null) {
        final existingEvent = byId(existingEventId);
        if (existingEvent != null) {
          // Event exists, check if it needs updating
          if (_hasChanged(existingEvent, newEvent)) {
            updateEvent(event: existingEvent, updatedEvent: newEvent);
          }
        }
      } else {
        // New mask, create event for it (only stores the ID string)
        final eventId = addEvent(newEvent);
        _maskIdToEventId[mask. id] = eventId;
      }
    }

    // Remove events for masks that no longer exist
    final toRemove = _maskIdToEventId.keys.where((id) => !maskIds.contains(id)).toList();
    for (final maskId in toRemove) {
      final eventId = _maskIdToEventId[maskId]! ;
      final event = byId(eventId);
      if (event != null) {
        removeEvent(event);
      }
      _maskIdToEventId.remove(maskId);
    }
  }

  /// Convert a Mask to a CalendarEvent< String >
  /// 
  /// Instead of storing the full Mask object, we only store the mask ID. 
  /// The actual Mask data is fetched from cache when needed.
  CalendarEvent<String> _maskToCalendarEvent(Mask mask) {
    return CalendarEvent<String>(
      data: mask.id,  // Only store the ID, not the entire Mask object! 
      dateTimeRange: DateTimeRange(
        start: mask.startTime,
        end: mask.endTime,
      ),
    );
  }

  /// Check if the event data has meaningfully changed
  /// 
  /// Since we only store IDs, we compare the date/time ranges
  bool _hasChanged(CalendarEvent<String> oldEvent, CalendarEvent<String> newEvent) {
    // The ID is the same (we're only updating if the ID matches)
    // But the date/time might have changed
    return oldEvent.dateTimeRange != newEvent.dateTimeRange;
  }
}