import 'package:flutter/material.dart';
import 'package:wyd_front/state/trash/event_range_controller.dart';

class WeekViewAdapter implements EventRangeController {
  // 💡 Composition: Hold a reference to the external library controller.
  //final WeekViewController _controller;
  final _controller;

  WeekViewAdapter(this._controller);

  // 1. Implementing Listenable methods by delegating to the wrapped controller
  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _controller.removeListener(listener);

  // 2. Implementing the core required property
  @override
  DateTimeRange get focusedRange {
    // This method safely calls the existing logic from the wrapped controller
    return _controller.weekRange();
  }

/*
  // 3. Delegating control methods
  @override
  void prev() => _controller.prev();

  @override
  void next() => _controller.next();

  @override
  void reset() => _controller.reset();

  @override
  void dispose() => _controller.dispose();*/
}

// 💡 Usage: 
// final libController = WeekViewController(...);
// final abstractController = WeekViewAdapter(libController);
// final notifier = WeekEventsNotifier(abstractController);