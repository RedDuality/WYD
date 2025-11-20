import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/state/event/range_controller.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/profileEvent/profile_events_cache.dart';
import 'package:wyd_front/state/user/view_settings_cache.dart';

class CurrentEventsProvider extends EventController {
  late ProfileEventsCache profileEventsProvider;
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

    _rangesSubscription = _storage.ranges.listen((updatedRange) {
      // if updates are in the current view, re-fetch the current week's events
      if (_controller != null && updatedRange.overlapsWith(_controller!.focusedRange)) {
        _synchWithStorage(updatedRange);
      }
    });

    _eventSubscription = _storage.updates.listen((event) {
      _updateEvent(event.$1, event.$2);
    });
  }

  void inject(ProfileEventsCache provider) {
    profileEventsProvider = provider;
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

    _retrieveEvents(logger: "Initial load");
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
    debugPrint("retrieveEvents, $logger");
    var newEvents = await EventStorageService.retrieveEventsInTimeRange(_controller!.focusedRange);
    _setEvents(newEvents);
  }

  void _setEvents(List<Event> newEvents) {
    _isLoading = false;
    super.removeWhere((event) => true);
    super.addAll(newEvents);

    if (_isLoading) {
      _isLoading = false;
      //notifyListeners(); // : already called from super
    }

    profileEventsProvider.rangeChanged(allEvents.whereType<Event>().map((event) => event.eventHash).toSet());
  }

  Future<void> _synchWithStorage(DateTimeRange range) async {
    var overlap = DateTimeRange(
      start: range.start.isAfter(_controller!.focusedRange.start) ? range.start : _controller!.focusedRange.start,
      end: range.end.isBefore(_controller!.focusedRange.end) ? range.end : _controller!.focusedRange.end,
    );

    var events = await EventStorage().getEventsInTimeRange(overlap);
    _addEvents(events);
  }

  void _addEvents(List<Event> newEvents) {
    super.addAll(newEvents);
    profileEventsProvider.rangeChanged(allEvents.whereType<Event>().map((event) => event.eventHash).toSet());
    //notifyListeners();
  }

  void _updateEvent(Event event, bool deleted) {
    if (_controller == null) return;

    final inTimeRange =
        _controller!.focusedRange.overlapsWith(DateTimeRange(start: event.startTime!, end: event.endTime!));
    final inMemory = allEvents.contains(event);

    // clean up the old copy
    if (inMemory) {
      super.remove(event);
      profileEventsProvider.remove(event.eventHash);
    }

    if (!deleted && (!inMemory || inTimeRange)) {
      super.add(event);
      profileEventsProvider.add(event.eventHash);
    }
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

    // get all events in date but that are also confirmed by the profiles I have the permission on to see
    // -> get all allowed profilesId(ViewSettings)
    // -> get events in date and from profileIds
    final todaysEventsIds = events
        .whereType<Event>()
        .where((event) => event.occursOnDate(date.toLocal()))
        .map((event) => event.eventHash)
        .toSet();
    final viewingProfileIds = ViewSettingsCache().getProfiles(_confirmedView);
    final eventIdsWhereConfirmed =
        ProfileEventsCache().eventsWithProfilesConfirmed(todaysEventsIds, viewingProfileIds, _confirmedView);

    return events.whereType<Event>().where((event) => eventIdsWhereConfirmed.contains(event.eventHash)).toList();
  }
}
