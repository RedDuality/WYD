import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:wyd_front/state/util/range_calculator.dart';

class MaskRangeController extends ChangeNotifier with RangeCalculator {
  // Store the main calendar controller
  final CalendarController<String> _calendarController;

  MaskRangeController(this._calendarController, {DateTime? initialDate, int numberOfDays = 7}) {
    final startDate = initialDate ?? DateTime.now();

    calculateRanges(startDate, numberOfDays);
  }

  void attach() {
    _calendarController.visibleDateTimeRange.addListener(_onVisibleRangeChanged);

    _onVisibleRangeChanged();
  }

  void _onVisibleRangeChanged() {
    final newRange = _calendarController.visibleDateTimeRange.value;

    if (newRange != null && (focusedRange.start != newRange.start || focusedRange.end != newRange.end)) {
      calculateRanges(newRange.start, RangeCalculator.calculateNumberOfDays(newRange));
      notifyListeners();
    }
  }

  void setRange(DateTime newDate, int visibleDays) {
    final newRange = RangeCalculator.calculateRange(newDate, visibleDays);

    if (focusedRange.start != newRange.start || focusedRange.end != newRange.end) {
      calculateRanges(newDate, visibleDays);

      _calendarController.animateToDate(newDate);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    try {
      _calendarController.visibleDateTimeRange.removeListener(_onVisibleRangeChanged);
    } catch (_) {}
    super.dispose();
  }
}
