import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/calendar_view_range_controller.dart';
import 'package:wyd_front/state/event/event_storage.dart';

class EventCacheService extends ChangeNotifier {
  List<Event> _currentEventsCache = [];
  bool _isLoading = true;

  final EventStorage _storage = EventStorage();
  final CalendarViewRangeController _rangeController;
  late final StreamSubscription _cacheSubscription;

  List<Event> get events => _currentEventsCache;
  bool get isLoading => _isLoading;

  EventCacheService(this._rangeController) {
    // Listen to range changes
    _rangeController.addListener(_retrieveRange);

    _synchWithStorage(); // Initial load
  }

  Future<void> _retrieveRange() async {
    var retrieveInterval = _rangeController.focusedRange;
    EventRetrieveService.retrieveMultiple(retrieveInterval);
    _synchWithStorage();
  }

  Future<void> _synchWithStorage() async {
    final displayedRange = _rangeController.focusedRange;

    final newEvents = await _storage.getEventsInTimeRange(displayedRange);

    _currentEventsCache = newEvents;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _rangeController.removeListener(_synchWithStorage);
    _cacheSubscription.cancel();
    super.dispose();
  }
}
