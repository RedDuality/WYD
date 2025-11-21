import 'package:flutter/material.dart';

/// An adapter that bridges the low-level onPageChange callback from the
/// calendar_view package to the high-level AbstractCalendarController interface.
class RangeController extends ChangeNotifier {
  late DateTimeRange _previousRange;
  late DateTimeRange _focusedRange;
  late DateTimeRange _futureRange;

  // Regular public constructor that accepts arguments
  RangeController(DateTime date, int numberOfDay) {
    _calculateRanges(date, numberOfDay);
  }
  
  DateTimeRange get previousRange => _previousRange;
  DateTimeRange get focusedRange => _focusedRange;
  DateTimeRange get futureRange => _futureRange;

  void setRange(DateTime newDate, int visibleDays) {
    final newRange = _calculateRange(newDate, visibleDays);

    // update and notify listeners only if the range has actually changed.
    if (_focusedRange.start != newRange.start || _focusedRange.end != newRange.end) {
      _calculateRanges(newDate, visibleDays);
      // CurrentViewEventProvider is listening, thus triggering an event list update
      notifyListeners();
    }
  }

  void _calculateRanges(DateTime currentDay, int visibleDays) {
    _focusedRange = _calculateRange(currentDay, visibleDays);
    _previousRange = _calculateRange(currentDay.add(Duration(days: -visibleDays)), visibleDays);
    _futureRange = _calculateRange(currentDay.add(Duration(days: visibleDays)), visibleDays);
  }

  static DateTimeRange _calculateRange(DateTime currentDay, int visibleDays) {
    // range starts from current week's monday
    var mondayOfRange = currentDay.subtract(Duration(days: currentDay.weekday - 1));
    DateTime startOfFirstDay = DateTime(mondayOfRange.year, mondayOfRange.month, mondayOfRange.day);

    var lastDay = mondayOfRange.add(Duration(days: visibleDays - 1));
    DateTime endOfRange = DateTime(lastDay.year, lastDay.month, lastDay.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    return DateTimeRange(
      start: startOfFirstDay,
      end: endOfRange,
    );
  }
}
