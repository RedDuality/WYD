import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/view/events/event_view_orchestrator.dart';

class EventsCache extends EventController {
  EventViewOrchestrator? _provider;

  final EventStorage _storage = EventStorage();

  late final StreamSubscription<DateTimeRange> _rangesChannel;
  late final StreamSubscription<(Event event, bool deleted)> _eventChannel;
  late final StreamSubscription<void> _clearAllChannel;

  DateTimeRange _rangeInCache =
      DateTimeRange(start: DateTime.fromMicrosecondsSinceEpoch(0), end: DateTime.fromMillisecondsSinceEpoch(1));

  EventsCache() {
    _rangesChannel = _storage.rangesChannel.listen((updatedRange) {
      _synchWithStorage(updatedRange);
    });

    _eventChannel = _storage.updatesChannel.listen((event) {
      if (event.$2) {
        _delete(event.$1);
      } else {
        _updateEvent(event.$1);
      }
    });

    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });
  }

  Future<void> _synchWithStorage(DateTimeRange updatedRange) async {
    if (!_rangeInCache.overlapsWith(updatedRange)) return;

    final overlap = _rangeInCache.getOverlap(updatedRange);
    if (overlap == null) return;

    var events = await _storage.getEventsInRange(overlap);

    if (events.isNotEmpty) {
      final eventIds = events.map((e) => e.id).toSet();
      await _provider!.onMultipleEventsAdded(eventIds);
      super.addAll(events);
    }
  }

  Future<void> _updateEvent(Event event) async {
    if (_provider == null) return;

    final range = _provider!.rangeCntrl.focusedRange;
    final inTimeRange = range.overlapsWith(DateTimeRange(start: event.startTime!, end: event.endTime!));

    if (inTimeRange) {
      Event? inMemoryEvent = allEvents.whereType<Event>().where((ev) => ev.id == event.id).firstOrNull;

      if (inMemoryEvent != event) {
        if (inMemoryEvent != null) {
          super.remove(inMemoryEvent);
        } else {
          await _provider!.onSingleEventAdded(event.id);
        }
        super.add(event);
      }
    }
  }

  void _delete(Event event) {
    Event? inMemoryEvent = allEvents.whereType<Event>().where((ev) => ev.id == event.id).firstOrNull;
    if (inMemoryEvent != null) {
      super.remove(event);
    }
  }

  Future<void> loadMasksForRange(DateTimeRange newRange) async {
    if (newRange == _rangeInCache) return;

    final eventsToBeRemoved = super
        .allEvents
        .whereType<Event>()
        .where((e) => !(e.endTime!.isAfter(newRange.start) && e.startTime!.isBefore(newRange.end)))
        .toList();

    super.removeAll(eventsToBeRemoved);

    final addedIntervals = _rangeInCache.getAddedIntervals(newRange);

    _rangeInCache = newRange;

    List<Event> eventsToBeAdded = [];
    for (final interval in addedIntervals) {
      var events = await EventStorageService.retrieveEventsInTimeRange(interval);
      eventsToBeAdded.addAll(events);
    }

    super.addAll(eventsToBeAdded);
  }

  void setViewProvider(EventViewOrchestrator? provider) {
    _provider = provider;

    if (_provider != null) {
      super.updateFilter(newFilter: _provider!.getFilteredEvents);
    } else {
      super.updateFilter(newFilter: (data, events) => <Event>[]);
    }
  }

  Event? get(String eventId) {
    for (final event in allEvents.whereType<Event>()) {
      if (event.id == eventId) return event;
    }
    return null;
  }

  void clearAll() {
    super.removeWhere((_) => true);
  }

  @override
  void dispose() {
    // super.allEvents.clear();
    _clearAllChannel.cancel();
    _rangesChannel.cancel();
    _eventChannel.cancel();
    super.dispose();
  }
}
