import 'package:flutter/material.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/state/util/range_calculator.dart';

class EventCurrentRangeController extends ChangeNotifier with RangeController {
  EventCurrentRangeController({DateTime? initialDate, int numberOfDays = 7}) {
    final startDate = initialDate ?? DateTime.now();

    init(startDate, numberOfDays);
  }

  void setRange(DateTime newDate, int visibleDays) {
    final newRange = RangeController.calculateRange(newDate, visibleDays);

    if (!currentRange.isSameAs(newRange)) {
      calculateRanges(newDate, visibleDays);
      notifyListeners();
    }
  }
}
