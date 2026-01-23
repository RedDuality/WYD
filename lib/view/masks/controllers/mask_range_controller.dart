import 'package:flutter/material.dart';
import 'package:wyd_front/state/util/range_calculator.dart';

class MaskRangeController extends ChangeNotifier with RangeController {

  MaskRangeController({DateTime? initialDate, int numberOfDays = 7}) {
    final startDate = initialDate ?? DateTime.now();

    init(startDate, numberOfDays);
  }

  void setRange(DateTimeRange newRange) {

    if (focusedRange.start != newRange.start || focusedRange.end != newRange.end ) {
      calculateRangesFromRange(newRange);
      notifyListeners();
    }
  }




/*
  void attach() {
    calendarController.visibleDateTimeRange.addListener(_onVisibleRangeChanged);

    _onVisibleRangeChanged();
  }

  void _onVisibleRangeChanged() {
    final newRange = calendarController.visibleDateTimeRange.value;

    if (newRange != null && (focusedRange.start != newRange.start || focusedRange.end != newRange.end)) {
      calculateRanges(newRange.start, RangeCalculator.calculateNumberOfDays(newRange));
      notifyListeners();
    }
  }

  void setRange(DateTime newDate, int visibleDays) {
    final newRange = RangeCalculator.calculateRange(newDate, visibleDays);

    if (focusedRange.start != newRange.start || focusedRange.end != newRange.end) {
      calculateRanges(newDate, visibleDays);

      calendarController.animateToDate(newDate);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    try {
      calendarController.visibleDateTimeRange.removeListener(_onVisibleRangeChanged);
    } catch (_) {}
    super.dispose();
  }*/
}
