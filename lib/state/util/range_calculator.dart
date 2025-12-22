import 'package:flutter/material.dart';

/// Provides reusable range calculation logic.
mixin RangeCalculator {
  late DateTimeRange totalRange;
  late DateTimeRange previousRange;
  late DateTimeRange focusedRange;
  late DateTimeRange futureRange;

  void calculateRanges(DateTime currentDay, int visibleDays) {
    focusedRange = calculateRange(currentDay, visibleDays);
    previousRange = calculateRange(currentDay.add(Duration(days: -visibleDays)), visibleDays);
    futureRange = calculateRange(currentDay.add(Duration(days: visibleDays)), visibleDays);

    totalRange = DateTimeRange(start: previousRange.start, end: futureRange.end);
  }

  static DateTimeRange calculateRange(DateTime currentDay, int visibleDays) {
    var mondayOfRange = currentDay.subtract(Duration(days: currentDay.weekday - 1));
    DateTime startOfFirstDay = DateTime(mondayOfRange.year, mondayOfRange.month, mondayOfRange.day);

    var lastDay = mondayOfRange.add(Duration(days: visibleDays - 1));
    DateTime endOfRange = DateTime(lastDay.year, lastDay.month, lastDay.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    return DateTimeRange(start: startOfFirstDay, end: endOfRange);
  }

  static int calculateNumberOfDays(DateTimeRange range) {
    return range.end.difference(range.start).inDays + 1;
  }
}
