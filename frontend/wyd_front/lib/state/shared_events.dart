import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wyd_front/model/my_event.dart';

class SharedEvents extends CalendarDataSource {
  SharedEvents() {
    appointments = <Appointment>[];
    resources = <CalendarResource>[];

    addAppointement((MyEvent(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 4)),
      isAllDay: false,
      subject: 'Meeting',
      color: Colors.blue,
      resourceIds: <Object>['0001', '0002'],
      startTimeZone: '',
      endTimeZone: '',
      recurrenceRule: "FREQ=DAILY;INTERVAL=1;COUNT=5",
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
