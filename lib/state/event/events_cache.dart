import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/model/events/recurrent_event.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/service/event/recurrent_event_storage_service.dart';
import 'package:wyd_front/state/event/event_intervals_cache.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/event/recurrent_event_storage.dart';
import 'package:wyd_front/view/events/event_view_orchestrator.dart';

// storageEventIntervals
// _rangeInCache
//

class EventsCache extends EventController {
  EventViewOrchestrator? _provider;

  final EventIntervalsCache _intervals = EventIntervalsCache();

  final EventStorage _storage = EventStorage();
  final RecurrentEventStorage _recurrentEventStorage = RecurrentEventStorage();

  late final StreamSubscription<DateTimeRange> _storageEventMassUpdate;

  late final StreamSubscription<(Event event, bool deleted)> _eventChannel;
  late final StreamSubscription<(RecurrentEvent event, bool deleted)> _recurrentEventChannel;

  late final StreamSubscription<void> _clearAllChannel;
  late final StreamSubscription<void> _clearAllRecurrentChannel;

  DateTimeRange _rangeInCache =
      DateTimeRange(start: DateTime.fromMicrosecondsSinceEpoch(0), end: DateTime.fromMillisecondsSinceEpoch(1));

  EventsCache() {
    _storageEventMassUpdate = _intervals.rangesChannel.listen((updatedRange) {
      _synchWithStorage(updatedRange);
    });

    _eventChannel = _storage.updatesChannel.listen((event) {
      if (event.$2) {
        _delete(event.$1);
      } else {
        _addOrUpdate(event.$1);
      }
    });

    _recurrentEventChannel = _recurrentEventStorage.updatesChannel.listen((event) {
      if (event.$2) {
        _deleteRecurrent(event.$1);
      } else {
        _addOrUpdateRecurrent(event.$1);
      }
    });

    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });

    _clearAllRecurrentChannel = _recurrentEventStorage.clearChannel.listen((_) {
      clearAll();
    });
  }

  Future _synchWithStorage(DateTimeRange updatedRange) async {
    final overlap = _rangeInCache.getOverlap(updatedRange);
    if (overlap == null) return;

    var events = await _retrieveEventsFromStorage(overlap);

    final instanceIds = events.$1.map((ev) => ev.id).toSet();
    final masterIds = events.$2.map((ev) => ev.masterEventId).toSet();

    await _provider!.onMultipleEventsAdded(instanceIds.union(masterIds));

    super.addAll(events.$1 + events.$2);
  }

  Future<(List<Event> instances, List<Event> generated)> _retrieveEventsFromStorage(DateTimeRange range) async {
    var events = await _storage.getEventsInRange(range);
    final detachedInstancesIds =
        events.where((e) => e.detachedInstance).map((e) => '${e.masterEventId}_${e.recurrencyInstanceId}').toSet();

    var generatedFromMasters = await RecurrentEventStorageService.generateEventsInTimeRange(range);
    generatedFromMasters.removeWhere((e) => detachedInstancesIds.contains(e.id));

    return (events, generatedFromMasters);
  }

  Future _addOrUpdate(Event event) async {
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

  Future<void> _addOrUpdateRecurrent(RecurrentEvent master) async {
    final cacheRangeStart = _intervals.getAbsoluteStart();
    final cacheRangeEnd = _intervals.getAbsoluteEnd();

    // 1. Get all instances from the RRule within the cache range
    final occurrences = master.recurrenceRule.getInstances(
      start: master.startTime!.toUtc(),
      after: cacheRangeStart,
      before: cacheRangeEnd,
    );

    // 2. Identify all events currently in the controller linked to this master
    final relatedEvents = allEvents.whereType<Event>().where((e) => e.masterEventId == master.id).toList();

    // 3. Separate: Find detached IDs (to skip) and generated events (to remove)
    final detachedInstanceIds =
        relatedEvents.where((e) => e.detachedInstance).map((e) => e.recurrencyInstanceId).toSet();

    // 4. Remove ONLY the generated instances
    final eventsToRemove = relatedEvents.where((e) => !e.detachedInstance).toList();
    if (eventsToRemove.isNotEmpty) {
      super.removeAll(eventsToRemove);
    }

    if (occurrences.isEmpty) return;

    // 5. Generate new instances, removing those that have a detached version
    final newInstances = master.expandOccurrences(occurrences);

    newInstances.removeWhere((i) => detachedInstanceIds.contains(i.recurrencyInstanceId));

    // 6. Batch add the new instances
    if (newInstances.isNotEmpty) {
      super.addAll(newInstances);
    }
  }

  void _deleteRecurrent(RecurrentEvent master) {
    super.removeAll(allEvents.whereType<Event>().where((e) => e.masterEventId == master.id).toList());
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

    if (eventsToBeRemoved.isNotEmpty) super.removeAll(eventsToBeRemoved);
  }

  Future<void> _addInRangeEvents(DateTimeRange range) async {
    final timeIntervalsNotYetInCache = _rangeInCache.getAddedIntervals(range);

    List<Event> eventsToBeAdded = [];
    for (final interval in timeIntervalsNotYetInCache) {
      _updateStorageFromServerIfNotCoveredYet(interval);

      var events = await _retrieveEventsFromStorage(interval);
      eventsToBeAdded.addAll(events.$1 + events.$2);
    }

    _rangeInCache = range;

    super.addAll(eventsToBeAdded);
  }

  void _updateStorageFromServerIfNotCoveredYet(DateTimeRange requestedInterval) {
    // if storage doesn't cover the full new interval, retrieve from server
    var rangeNotInStorage = EventIntervalsCache().getMissingInterval(requestedInterval);
    if (rangeNotInStorage != null) unawaited(EventStorageService.retrieveFromServer(rangeNotInStorage));
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
    _clearAllRecurrentChannel.cancel();
    _storageEventMassUpdate.cancel();
    _eventChannel.cancel();
    _recurrentEventChannel.cancel();
    super.dispose();
  }
}
