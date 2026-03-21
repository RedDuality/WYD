import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/model/events/recurrent_event.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/event/event_intervals_cache.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/view/events/event_view_orchestrator.dart';

class EventsCache extends EventController {
  EventViewOrchestrator? _provider;

  final EventStorage _storage = EventStorage();
  final EventIntervalsCache _intervals = EventIntervalsCache();

  late final StreamSubscription<DateTimeRange> _rangesChannel;

  late final StreamSubscription<(Event event, bool deleted)> _eventChannel;
  late final StreamSubscription<(RecurrentEvent event, bool deleted)> _recurrentEventChannel;
  
  late final StreamSubscription<void> _clearAllChannel;

  DateTimeRange _rangeInCache =
      DateTimeRange(start: DateTime.fromMicrosecondsSinceEpoch(0), end: DateTime.fromMillisecondsSinceEpoch(1));

  EventsCache() {
    _rangesChannel = _intervals.rangesChannel.listen((updatedRange) {
      _synchWithStorage(updatedRange);
    });

    _eventChannel = _storage.updatesChannel.listen((event) {
      if (event.$2) {
        _delete(event.$1);
      } else {
        _addOrUpdate(event.$1);
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

  Future<void> _addOrUpdate(Event event) async {
    final range = _provider?.rangeCntrl.currentRange ?? _rangeInCache;
    final inCacheTimeRange = range.overlapsWith(DateTimeRange(start: event.startTime!, end: event.endTime!));

    final inMemoryEvent = _getOldEvent(event);

    if (inCacheTimeRange) {
      if (inMemoryEvent != null) {
        // update
        if (inMemoryEvent != event) {
          super.remove(inMemoryEvent);
          if (_wasGeneratedButIsNowDetached(event, inMemoryEvent)) {
            // id changed
            await _provider?.onSingleEventAdded(event.id);
          }
          super.add(event);
        }
        // do nothing, as the update was just a sync and with no changes happening
      } else {
        // add
        await _provider?.onSingleEventAdded(event.id); // loadProfileEvents in cache
        super.add(event);
      }
    }
  }

  Event? _getOldEvent(Event event) {
    if (event.detachedInstance) {
      return allEvents
          .whereType<Event>()
          .where(
              (ev) => ev.masterEventId == event.masterEventId && ev.recurrencyInstanceId == event.recurrencyInstanceId)
          .firstOrNull;
    }

    return allEvents.whereType<Event>().where((ev) => ev.id == event.id).firstOrNull;
  }

  bool _wasGeneratedButIsNowDetached(Event newEvent, Event old) {
    return old.id == '${newEvent.masterEventId}_${newEvent.recurrencyInstanceId}';
  }

  void _delete(Event event) {
    Event? inMemoryEvent = allEvents.whereType<Event>().where((ev) => ev.id == event.id).firstOrNull;
    if (inMemoryEvent != null) {
      super.remove(event);
    }
  }

  Future<void> loadEventsForRange(DateTimeRange newRange) async {
    if (newRange == _rangeInCache) return;

    _removeOutOfRangeEvents(newRange);

    await _addInRangeEvents(newRange);
  }

  void _removeOutOfRangeEvents(DateTimeRange range) {
    final eventsToBeRemoved = super
        .allEvents
        .whereType<Event>()
        .where((e) => !(e.endTime!.isAfter(range.start) && e.startTime!.isBefore(range.end)))
        .toList();

    if (eventsToBeRemoved.isNotEmpty) {
      super.removeAll(eventsToBeRemoved);
    }
  }

  Future<void> _addInRangeEvents(DateTimeRange range) async {
    final addedIntervals = _rangeInCache.getAddedIntervals(range);

    List<Event> eventsToBeAdded = [];
    for (final interval in addedIntervals) {
      var events = await EventStorageService.retrieveEventsInTimeRange(interval);
      eventsToBeAdded.addAll(events);
    }

    _rangeInCache = range;

    super.addAll(eventsToBeAdded);
  }

  void setViewProvider(EventViewOrchestrator? provider) {
    _provider = provider;

    if (_provider != null) {
      super.updateFilter(newFilter: _provider!.getFilteredEvents);
    } else {
      // FIX: Wrap in a microtask to defer notifyListeners() until the
      // framework is unlocked after the dispose phase.
      Future.microtask(() {
        super.updateFilter(newFilter: (data, events) => <Event>[]);
      });
    }
  }

  Event? get(String eventId) {
    for (final event in allEvents.whereType<Event>()) {
      if (event.id == eventId) return event;
    }
    return null;
  }

  /// Returns any event in cache currently occupying the given recurrence slot.
  Event? getByRecurrenceInstance(String masterEventId, String instanceId) {
    for (final event in allEvents.whereType<Event>()) {
      if (event.masterEventId == masterEventId && event.recurrencyInstanceId == instanceId) {
        return event;
      }
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
