import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wyd_front/model/model.dart';

class PrivateEvents extends CalendarDataSource {
  PrivateEvents() {
    appointments = <Appointment>[];
    resources = <CalendarResource>[];
    addAppointement((MyEvent(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      isAllDay: false,
      subject: 'Meeting',
      color: Colors.blue,
      resourceIds: <Object>['0001', '0002'],
      startTimeZone: 'Central Brazilian Standard Time',
      endTimeZone: '',
      recurrenceRule: "FREQ=DAILY;INTERVAL=1;COUNT=10",
      recurrenceExceptionDates: <DateTime>[
        DateTime.now().add(const Duration(days: 2)),
        DateTime.now().add(const Duration(days: 3))
      ],
      notes: 'notes',
      location: '',
    )));
  }

  addAppointements(List<Appointment> events) {
    appointments!.addAll(events);
  }

  void addAppointement(MyEvent event) {
    appointments!.add(event);
    notifyListeners(CalendarDataSourceAction.add, appointments!);
  }
}
