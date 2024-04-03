import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> events, List<CalendarResource> resources) {
    appointments = events;
    resources = resources;
  }
}

class MyEvent extends Appointment {

  String link;

  MyEvent({
    super.notes,
    required super.startTime,
    required super.endTime,
    super.isAllDay,
    super.subject,
    super.color,
    super.startTimeZone,
    super.endTimeZone,
    super.recurrenceRule,
    super.recurrenceExceptionDates,
    super.location,
    super.resourceIds,
    super.recurrenceId,
    super.id,
    this.link = '',
  }) ;


  
}
