import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:wyd_front/model/mask/mask.dart';

class CalendarMask extends CalendarEvent<String> {
  CalendarMask({
    required Mask mask,
    super.canModify,
    super.interaction,
  }) : super(
          dateTimeRange: DateTimeRange(start: mask.startTime, end: mask.endTime),
          data: mask.id,
        );
  String get maskId => data!;
}
