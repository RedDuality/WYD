import 'package:flutter/material.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/state/util/range_calculator.dart';

class MaskRangeController extends ChangeNotifier with RangeController {

  MaskRangeController({DateTime? initialDate, int numberOfDays = 7}) {
    final startDate = initialDate ?? DateTime.now();

    init(startDate, numberOfDays);
  }

  void setRange(DateTimeRange newRange) {

    if (!currentRange.isSameAs(newRange)) {
      calculateRangesFromRange(newRange);
      notifyListeners();
    }
  }

}
