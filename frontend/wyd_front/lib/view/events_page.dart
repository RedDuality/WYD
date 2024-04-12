import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
//import 'package:wyd_front/model/model.dart';

class EventsPage extends StatelessWidget{
  const EventsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.week,
        firstDayOfWeek: 1,
        //dataSource: ,
        //monthViewSettings: const MonthViewSettings(showAgenda: true),
      ));
  }
}

