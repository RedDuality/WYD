import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/state/event/events_cache.dart';
import 'package:wyd_front/state/event/event_range_controller.dart';
import 'package:wyd_front/state/media/media_flag_cache.dart';
import 'package:wyd_front/state/profile/detailed_profiles_cache.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_cache.dart';
import 'package:wyd_front/state/user/view_settings_cache.dart';

class EventViewOrchestrator with ChangeNotifier {
  final DetailedProfileCache _detProfCh;
  final ViewSettingsCache _viewSetsCh;
  final DetailedProfileEventsCache _profEventsCh;

  final MediaFlagCache _mediaFlagCh;
  final EventsCache _eventsCache;

  final EventRangeController _rangeController;

  bool _confirmedView = true;
  bool _isLoading = true;


  EventViewOrchestrator({
    required EventsCache eventsCache,
    required DetailedProfileCache dpCache,
    required DetailedProfileEventsCache profEventsCache,
    required ViewSettingsCache vsCache,
    required MediaFlagCache mfCache,
    required EventRangeController rangeController,
    required bool confirmedView,
  })  : _detProfCh = dpCache,
        _eventsCache = eventsCache,
        _profEventsCh = profEventsCache,
        _viewSetsCh = vsCache,
        _mediaFlagCh = mfCache,
        _rangeController = rangeController,
        _confirmedView = confirmedView;

  void initialize() {
    _profEventsCh.setViewProvider(this);
    _eventsCache.setViewProvider(this);

    _detProfCh.addListener(notifyListeners); // for color changes
    _profEventsCh.addListener(notifyListeners);
    _viewSetsCh.addListener(notifyListeners);
    _mediaFlagCh.addListener(notifyListeners);
    _eventsCache.addListener(notifyListeners); 

    rangeCntrl.addListener(() {
      _onRangeChange(logger: "fromPageUpdate");
    });

    _onRangeChange(logger: "InitialLoad");
  }

  EventsCache get eventCntrl => _eventsCache;
  EventRangeController get rangeCntrl => _rangeController;

  bool get confirmedView => _confirmedView;

  Future<void> _onRangeChange({String logger = ""}) async {
    _isLoading = true;

    debugPrint("retrieveEvents, $logger");

    await _eventsCache.loadMasksForRange(rangeCntrl.focusedRange);

    await _profEventsCh.synchWithCachedEvents();

    _isLoading = false;

    notifyListeners();
  }

  // some events have been added to the storage
  Future<void> onMultipleEventsAdded(Set<String> eventIds) async {
    _isLoading = true;
    await _profEventsCh.loadCorrespondingProfileEvents(eventIds);
    _isLoading = false;
    //notifyListeners();
  }

  Future<void> onSingleEventAdded(String eventId) async {
    await _profEventsCh.loadProfileEvents(eventId);
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
    if (rangeCntrl.focusedRange.end.isBefore(date) || rangeCntrl.focusedRange.start.isAfter(date)) return [];

    var todaysEvents = events.whereType<Event>().where((event) => event.occursOnDate(date.toLocal()));
    final todaysEventsIds = todaysEvents.map((event) => event.id).toSet();
    //debugPrint("todays total: ${todaysEventsIds.length}");

    final viewingProfileIds = _viewSetsCh.getProfiles(_confirmedView);
    //debugPrint("profiles total: ${viewingProfileIds.length}");

    final eventIdsWhereConfirmed = _profEventsCh.eventsWithProfilesConfirmed(
      todaysEventsIds,
      profileIds: viewingProfileIds,
      confirmed: _confirmedView,
    );
    //debugPrint("confirmed total: ${eventIdsWhereConfirmed.length}");

    return events.whereType<Event>().where((event) => eventIdsWhereConfirmed.contains(event.id)).toList();
  }

  @override
  void dispose() {
    rangeCntrl.removeListener(_onRangeChange);
    _profEventsCh.removeListener(notifyListeners);
    _viewSetsCh.removeListener(notifyListeners);
    //_eventsCache.removeListener(notifyListeners);

    _profEventsCh.setViewProvider(null);
    _eventsCache.setViewProvider(null);
    super.dispose();
  }
}
