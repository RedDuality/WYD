import 'package:flutter/material.dart';


/// An adapter that bridges the low-level onPageChange callback from the
/// calendar_view package to the high-level AbstractCalendarController interface.
class CalendarViewRangeController extends ChangeNotifier{
  DateTimeRange _focusedRange;

  // Regular public constructor that accepts arguments
  CalendarViewRangeController(DateTime date, int numberOfDay) : _focusedRange = _calculateRange(date, numberOfDay);

  DateTimeRange get focusedRange => _focusedRange;

  void setRange(DateTime newDate, int visibleDays) {
    final newRange = _calculateRange(newDate, visibleDays);

    // update and notify listeners only if the range has actually changed.
    if (_focusedRange.start != newRange.start || _focusedRange.end != newRange.end) {
      _focusedRange = newRange;
      // CurrentViewEventProvider is listening, thus triggering an event list update
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // This is called when the adapter is no longer needed (e.g., in a provider's dispose)
    super.dispose();
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
