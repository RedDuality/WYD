import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/state/event/events_cache.dart';
import 'package:wyd_front/state/event/range_controller.dart';
import 'package:wyd_front/state/media/media_flag_cache.dart';
import 'package:wyd_front/state/profile/detailed_profiles_cache.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_cache.dart';
import 'package:wyd_front/state/user/view_settings_cache.dart';

class EventViewOrchestrator with ChangeNotifier {

  final DetailedProfileCache _dpCache;
  final ViewSettingsCache _vsCache;
  final DetailedProfileEventsCache _peCache;

  final MediaFlagCache _mfCache;
  final EventsCache _eventsCache;

  final RangeController _controller;
  bool _confirmedView = true;
  bool _isLoading = true;

  StreamSubscription<void>? _colorChangeSubscription;

  EventViewOrchestrator({
    required EventsCache eventsCache,
    required DetailedProfileCache dpCache,
    required DetailedProfileEventsCache peCache,
    required ViewSettingsCache vsCache,
    required MediaFlagCache mfCache,
    required RangeController rangeController,
    required bool confirmedView,
  })  : _dpCache = dpCache,
        _eventsCache = eventsCache,
        _peCache = peCache,
        _vsCache = vsCache,
        _mfCache = mfCache,
        _controller = rangeController,
        _confirmedView = confirmedView;

  void initialize() {
    _peCache.setViewProvider(this);
    _eventsCache.setViewProvider(this);

    _dpCache.addListener(_updateView);// for color changes
    _peCache.addListener(_updateView);
    _vsCache.addListener(_updateView);
    _mfCache.addListener(_updateView);
    _eventsCache.addListener(_updateView);


    controller.addListener(() {
      _onRangeChange(logger: "fromPageUpdate");
    });

    _onRangeChange(logger: "InitialLoad");
  }

  RangeController get controller => _controller;
  bool get confirmedView => _confirmedView;

  void _updateView() {
    // because WeekView wants an EventController
    notifyListeners();
  }

  Future<void> _onRangeChange({String logger = ""}) async {
    _isLoading = true;

    debugPrint("retrieveEvents, $logger");

    await _eventsCache.onRangeChange(controller.focusedRange);

    await _peCache.synchWithCachedEvents();

    _isLoading = false;

    _updateView();
  }

  // some events have been added to the storage
  Future<void> onMultipleEventsAdded(Set<String> eventIds) async {
    _isLoading = true;
    await _peCache.loadCorrespondingProfileEvents(eventIds);
    _isLoading = false;
    //_updateView();
  }

  Future<void> onSingleEventAdded(String eventId) async {
    await _peCache.loadProfileEvents(eventId);
  }

  Set<String> currentEventsIds() {
    return _eventsCache.allEvents.whereType<Event>().map((e) => e.id).toSet();
  }

  void changeMode(bool privateMode) {
    _confirmedView = privateMode;
    notifyListeners();
  }

  // Method exposed to the EventsCache filter
  List<Event> getFilteredEvents(DateTime date, List<CalendarEventData> events) {
    if (_isLoading) return [];
    if (controller.focusedRange.end.isBefore(date) || controller.focusedRange.start.isAfter(date)) return [];

    var todaysEvents = events.whereType<Event>().where((event) => event.occursOnDate(date.toLocal()));
    final todaysEventsIds = todaysEvents.map((event) => event.id).toSet();
    //debugPrint("todays total: ${todaysEventsIds.length}");

    final viewingProfileIds = _vsCache.getProfiles(_confirmedView);
    //debugPrint("profiles total: ${viewingProfileIds.length}");

    final eventIdsWhereConfirmed = _peCache.eventsWithProfilesConfirmed(
      todaysEventsIds,
      profileIds: viewingProfileIds,
      confirmed: _confirmedView,
    );
    //debugPrint("confirmed total: ${eventIdsWhereConfirmed.length}");

    return events.whereType<Event>().where((event) => eventIdsWhereConfirmed.contains(event.id)).toList();
  }

  @override
  void dispose() {
    controller.removeListener(_onRangeChange);
    _colorChangeSubscription?.cancel();
    _peCache.removeListener(_updateView);
    _vsCache.removeListener(_updateView);
    _eventsCache.removeListener(_updateView);

    _peCache.setViewProvider(null);
    _eventsCache.setViewProvider(null);
    super.dispose();
  }
}
