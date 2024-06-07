import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wyd_front/model/my_event.dart';

class Events extends CalendarDataSource {
  Events() {
    appointments = <Appointment>[];
    resources = <CalendarResource>[];
  }

  void setAppointements(List<Appointment> events) {
    appointments = events;
    notifyListeners(CalendarDataSourceAction.add, appointments!);
  }

  void addAppointement(MyEvent event) {
    appointments!.add(event);
    notifyListeners(CalendarDataSourceAction.add, appointments!);
  }
}
