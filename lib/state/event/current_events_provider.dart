import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/state/event/range_controller.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';

class CurrentEventsProvider extends EventController {
  bool _confirmedView = true;
  //Set<Event> _currentEventsCache = {};
  bool _isLoading = true;

  final EventStorage _storage = EventStorage();
  RangeController? _controller;
  StreamSubscription<DateTimeRange>? _rangesSubscription;
  StreamSubscription<(Event, bool)>? _eventSubscription;

  StreamSubscription<void>? _colorChangeSubscription;

  //List<Event> get events => _currentEventsCache.toList();

  bool get isLoading => _isLoading;

  CurrentEventsProvider() {
    super.updateFilter(newFilter: (date, events) => myEventFilter(date, events));

    _colorChangeSubscription = EventViewService.onProfileColorChangedStream.listen((_) {
      refresh();
    });
    // Whenever the storage says data changed, re-fetch the current week's events
    _rangesSubscription = _storage.ranges.listen((updatedRange) {
      _synchWithStorage(updatedRange);
    });

    _eventSubscription = _storage.updates.listen((event) {
      _updateEvent(event.$1, event.$2);
    });
  }

  void initialize(RangeController controller, bool confirmedView) {
    _confirmedView = confirmedView;

    // Clean up any previous controller/listeners if re-initializing
    _controller?.removeListener(_retrieveEvents);

    _controller = controller;

    // Listen to date changes from the range controller
    _controller!.addListener(() {
      _retrieveEvents(logger: "fromPageUpdate");
    });

    _retrieveEvents(logger: ""); // Initial load
  }

  Event? get(String eventHash) {
    for (final event in allEvents.whereType<Event>()) {
      if (event.eventHash == eventHash) return event;
    }
    return null;
  }

// triggers a view update
  void refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> _retrieveEvents({String? logger}) async {
    if (_controller == null) return;
    if (!_isLoading) {
      _isLoading = true;
    }
    var newEvents = await EventStorageService.retrieveEventsInTimeRange(_controller!.focusedRange);
    setEvents(newEvents);
  }

  Future<void> _synchWithStorage(DateTimeRange range) async {
    if (_controller == null) return;
    if (range.overlapsWith(_controller!.focusedRange)) {
      var overlap = DateTimeRange(
        start: range.start.isAfter(_controller!.focusedRange.start) ? range.start : _controller!.focusedRange.start,
        end: range.end.isBefore(_controller!.focusedRange.end) ? range.end : _controller!.focusedRange.end,
      );

      var updatedEvents = await EventStorageService.retrieveEventsInTimeRange(overlap);

      addEvents(updatedEvents);
    }
  }

  void _updateEvent(Event event, bool deleted) {
    if (_controller == null) return;

    final isFocused =
        _controller!.focusedRange.overlapsWith(DateTimeRange(start: event.startTime!, end: event.endTime!));
    final exists = allEvents.contains(event);

    if (exists) {
      remove(event);
    }

    if (!deleted && (!exists || isFocused)) {
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
    _controller?.removeListener(_retrieveEvents);
    _rangesSubscription?.cancel();
    _eventSubscription?.cancel();
    _colorChangeSubscription?.cancel();
    super.dispose();
  }

  /*
  Event? findEventByHash(String eventHash) {
    return allEvents.whereType<Event>().where((e) => e.eventHash == eventHash).firstOrNull;
  }
*/
  void changeMode(bool privateMode) {
    _confirmedView = privateMode;
    notifyListeners();
  }

  List<Event> myEventFilter<T extends Object?>(DateTime date, List<CalendarEventData<T>> events) {
    if (_isLoading) return [];
    if (_controller!.focusedRange.end.isBefore(date) || _controller!.focusedRange.start.isAfter(date)) return [];
    return events
        .whereType<Event>()
        .where((event) => event.occursOnDate(date.toLocal()) && event.currentConfirmed() == _confirmedView // &&
            //(confirmedView || event.endDate.isAfter(DateTime.now()))
            )
        .toList();
  }
}
