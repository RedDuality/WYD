import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:wyd_front/state/util/range_calculator.dart';

class MaskRangeController extends ChangeNotifier with RangeCalculator {
  late final MultiDayViewController _viewController;

  MaskRangeController(this._viewController, {DateTime? initialDate, int numberOfDays = 7}) {
    final startDate = initialDate ?? DateTime.now();
    calculateRanges(startDate, numberOfDays);

    _viewController.visibleDateTimeRange.addListener(_onVisibleRangeChanged);
  }

  void _onVisibleRangeChanged() {
    final newRange = _viewController.visibleDateTimeRange.value;

    if (focusedRange.start != newRange.start || focusedRange.end != newRange.end) {
      calculateRanges(newRange.start, RangeCalculator.calculateNumberOfDays(newRange));
      notifyListeners();
    }
  }

  void setRange(DateTime newDate, int visibleDays) {
    final newRange = RangeCalculator.calculateRange(newDate, visibleDays);

    if (focusedRange.start != newRange.start || focusedRange.end != newRange.end) {
      calculateRanges(newDate, visibleDays);
      _viewController.animateToDate(newDate);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _viewController.visibleDateTimeRange.removeListener(_onVisibleRangeChanged);
    super.dispose();
  }
}
