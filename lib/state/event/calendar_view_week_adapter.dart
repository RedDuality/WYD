import 'package:flutter/material.dart';
import 'package:wyd_front/state/event/abstract_event_range_controller.dart';

/// An adapter that bridges the low-level onPageChange callback from the
/// calendar_view package to the high-level AbstractCalendarController interface.
class CalendarViewWeekAdapter extends ChangeNotifier implements AbstractEventRangeController {
  // Represents the currently visible week range (7 days).
  DateTimeRange _focusedRange;

  // The calendar_view's WeekView displays 7 days.
  static const int _visibleDays = 7;

  // Initialize the range to the current week when the adapter is created.
  static final CalendarViewWeekAdapter _instance = CalendarViewWeekAdapter._internal();
  factory CalendarViewWeekAdapter() => _instance;

  CalendarViewWeekAdapter._internal() : _focusedRange = _calculateRange(DateTime.now());

  static DateTimeRange _calculateRange(DateTime date) {
    // The calendar_view extension for firstDayOfWeek and lastDayOfWeek
    // is needed here. Assuming a structure similar to what the library uses.

    // Simplistic calculation: Find the Monday of the week
    DateTime startOfWeek = startOfDay(date.subtract(Duration(days: date.weekday - 1)));
    DateTime endOfWeek = endOfDay(startOfWeek.add(const Duration(days: _visibleDays - 1)));

    // Ensure range covers full days
    return DateTimeRange(
      start: startOfWeek,
      end: endOfWeek,
    );
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
  }

  @override
  DateTimeRange get focusedRange => _focusedRange;

  /// This is the crucial method to be called from the WeekView's onPageChange.
  void updateFocusedDate(DateTime newDate) {
    final newRange = _calculateRange(newDate);

    // Only update and notify listeners if the range has actually changed.
    if (_focusedRange.start != newRange.start || _focusedRange.end != newRange.end) {
      _focusedRange = newRange;
      notifyListeners();
    }
  }

  // --- AbstractCalendarController Control Methods ---

  // NOTE: Implementing these requires access to the library's PageController
  // (which is private in WeekViewState), so they are best left unimplemented
  // or implemented to delegate to a helper that stores the PageController.
  // For simplicity and correctness with this library's API, we will keep them
  // as no-ops since external control is difficult without modifying WeekViewState.

  @override
  void prev() {/* Needs access to PageController to scroll backwards */}

  @override
  void next() {/* Needs access to PageController to scroll forwards */}

  @override
  void reset() {/* Needs access to PageController to jump to today */}

  @override
  void dispose() {
    // This is called when the adapter is no longer needed (e.g., in a provider's dispose)
    super.dispose();
  }
}
