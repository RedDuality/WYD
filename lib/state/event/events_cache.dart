import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/event_view_orchestrator.dart';

class EventsCache extends EventController {
  EventViewOrchestrator? _provider;

  final EventStorage _storage = EventStorage();

  StreamSubscription<DateTimeRange>? _rangesSubscription;
  StreamSubscription<(Event, bool)>? _eventSubscription;

  EventsCache() {

    _rangesSubscription = _storage.ranges.listen((updatedRange) {
      if (_provider != null && updatedRange.overlapsWith(_provider!.controller.focusedRange)) {
        _synchWithStorage(updatedRange);
      }
    });

    _eventSubscription = _storage.updates.listen((event) {
      if (event.$2) {
        _delete(event.$1);
      } else {
        _updateEvent(event.$1);
      }
    });
  }

  void setViewProvider(EventViewOrchestrator? provider) {
    _provider = provider;

    if (_provider != null) {
      super.updateFilter(newFilter: _provider!.getFilteredEvents);
    } else {
      super.updateFilter(newFilter: (data, events) => <Event>[]);
    }
  }

  Future<void> _synchWithStorage(DateTimeRange range) async {
    final range = _provider!.controller.focusedRange;
    final overlap = DateTimeRange(
      start: range.start.isAfter(range.start) ? range.start : range.start,
      end: range.end.isBefore(range.end) ? range.end : range.end,
    );

    var events = await _storage.getEventsInRange(overlap);

    if (events.isNotEmpty) {
      final eventIds = events.map((e) => e.id).toSet();
      await _provider!.onMultipleEventsAdded(eventIds);
      super.addAll(events);
    }
  }

  void _delete(Event event) {
    Event? inMemoryEvent = allEvents.whereType<Event>().where((ev) => ev.id == event.id).firstOrNull;
    if (inMemoryEvent != null) {
      super.remove(event);
    }
  }

  Future<void> _updateEvent(Event event) async {
    if (_provider == null) return;
    final range = _provider!.controller.focusedRange;
    final inTimeRange = range.overlapsWith(DateTimeRange(start: event.startTime!, end: event.endTime!));

    Event? inMemoryEvent = allEvents.whereType<Event>().where((ev) => ev.id == event.id).firstOrNull;

    final adding = inMemoryEvent == null;
    final updating = inMemoryEvent != null;

    if (inMemoryEvent != event) {
      if (updating) {
        event.hasCachedMedia = inMemoryEvent.hasCachedMedia;
        super.remove(inMemoryEvent);
      }

      if (adding || inTimeRange) {
        super.add(event);
      }
    }
  }

  void overwrite(List<Event> events) {
    if (super.allEvents.isNotEmpty) super.removeWhere((_) => true);
    super.addAll(events);
  }

  Event? get(String eventId) {
    for (final event in allEvents.whereType<Event>()) {
      if (event.id == eventId) return event;
    }
    return null;
  }

  // triggers a view update
  void refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // super.allEvents.clear();
    _rangesSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }
}
