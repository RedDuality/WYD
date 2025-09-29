import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/state/event/abstract_event_range_controller.dart';
import 'package:wyd_front/state/event/event_storage.dart';

class CurrentEventsNotifier extends ChangeNotifier {
  List<Event> _currentEventsCache = [];
  bool _isLoading = true;

  final EventStorage _storage = EventStorage();
  final AbstractEventRangeController  _controller;
  late final StreamSubscription _cacheSubscription;

  List<Event> get events => _currentEventsCache;
  bool get isLoading => _isLoading;

  CurrentEventsNotifier(this._controller) {
    // Listen to date changes from the calendar controller
    _controller.addListener(_fetchEventsForDisplayedWeek);

    // Whenever the cache says data changed, re-fetch the current week's events
    _cacheSubscription = _storage.updates.listen((_) {
      _fetchEventsForDisplayedWeek(isCacheUpdate: true);
    });

    _fetchEventsForDisplayedWeek(); // Initial load
  }

  Future<void> _fetchEventsForDisplayedWeek({bool isCacheUpdate = false}) async {
    // Avoid unnecessary loading state changes if it's just a data update
    if (!isCacheUpdate) {
      _isLoading = true;
      notifyListeners();
    }

    final displayedRange = _controller.focusedRange;

    final newEvents = await _storage.getEventsInTimeRange(
      periodStartTime: displayedRange.start,
      periodEndTime: displayedRange.end,
    );

    _currentEventsCache = newEvents;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.removeListener(_fetchEventsForDisplayedWeek);
    _cacheSubscription.cancel();
    super.dispose();
  }
}
