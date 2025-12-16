import 'package:flutter/material.dart';
import 'package:wyd_front/state/util/range_calculator.dart';

class EventRangeController extends ChangeNotifier with RangeCalculator {
  EventRangeController(DateTime date, int numberOfDay) {
    calculateRanges(date, numberOfDay);
  }

  void setRange(DateTime newDate, int visibleDays) {
    final newRange = RangeCalculator.calculateRange(newDate, visibleDays);

    if (focusedRange.start != newRange.start || focusedRange.end != newRange.end) {
      calculateRanges(newDate, visibleDays);
      notifyListeners();
    }
  }
}
