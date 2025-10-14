import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/state/event/range_controller.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';

class CurrentEventsProvider extends EventController {
  bool confirmedView = true;
  //Set<Event> _currentEventsCache = {};
  bool _isLoading = true;

  final EventStorage _storage = EventStorage();
  final RangeController _controller;
  late final StreamSubscription<DateTimeRange> _rangesSubscription;
  late final StreamSubscription<Event> _eventSubscription;

  //List<Event> get events => _currentEventsCache.toList();

  bool get isLoading => _isLoading;

  CurrentEventsProvider(this._controller, this.confirmedView) {
    super.updateFilter(newFilter: (date, events) => myEventFilter(date, events));
    // Listen to date changes from the range controller
    _controller.addListener(() {
      _retrieveEvents(logger: "fromPageUpdate");
    });

    // Whenever the storage says data changed, re-fetch the current week's events
    _rangesSubscription = _storage.ranges.listen((updatedRange) {
      _synchWithStorage(updatedRange);
    });

    _eventSubscription = _storage.updates.listen((event) {
      _updateEvent(event);
    });

    _retrieveEvents(logger: ""); // Initial load
  }

  Future<void> _retrieveEvents({String? logger}) async {
    if (!_isLoading) {
      _isLoading = true;
    }
    var newEvents = await EventStorageService.retrieveEventsInTimeRange(_controller.focusedRange);
    setEvents(newEvents);
  }

  Future<void> _synchWithStorage(DateTimeRange range) async {
    if (range.overlapsWith(_controller.focusedRange)) {
      var overlap = DateTimeRange(
        start: range.start.isAfter(_controller.focusedRange.start) ? range.start : _controller.focusedRange.start,
        end: range.end.isBefore(_controller.focusedRange.end) ? range.end : _controller.focusedRange.end,
      );

      var updatedEvents = await EventStorageService.retrieveEventsInTimeRange(overlap);

      addEvents(updatedEvents);
    }
  }

  void _updateEvent(Event event) {
    if (allEvents.contains(event)) {
      remove(event);
      super.add(event);
      //notifyListeners();
    } else if(_controller.focusedRange.overlapsWith(DateTimeRange(start: event.startTime!, end: event.endTime!))){
      super.add(event);
    }
  }

  void setEvents(List<Event> events) {
    _isLoading = false;
    super.removeWhere((event) => true);
    super.addAll(events);

    if (_isLoading) {
      _isLoading = false;
      //notifyListeners();
    }
  }

  void addEvents(List<Event> newEvents) {
    super.addAll(newEvents);
    //notifyListeners();
  }

  @override
  void dispose() {
    // super.allEvents.clear();
    _controller.removeListener(_retrieveEvents);
    _rangesSubscription.cancel();
    _eventSubscription.cancel();
    super.dispose();
  }

  /*
  Event? findEventByHash(String eventHash) {
    return allEvents.whereType<Event>().where((e) => e.eventHash == eventHash).firstOrNull;
  }
*/
  void changeMode(bool privateMode) {
    confirmedView = privateMode;
    notifyListeners();
    //myUpdateFilter();
  }

// triggers a view update
  void refresh() {
    notifyListeners();
  }

  List<Event> myEventFilter<T extends Object?>(DateTime date, List<CalendarEventData<T>> events) {
    if (_isLoading) return [];
    if (_controller.focusedRange.end.isBefore(date) || _controller.focusedRange.start.isAfter(date)) return [];
    return events
        .whereType<Event>()
        .where((event) => event.occursOnDate(date.toLocal()) &&
            event.currentConfirmed() == confirmedView // &&
            //(confirmedView || event.endDate.isAfter(DateTime.now()))
            )
        .toList();
  }
}

