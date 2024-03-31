import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventsPage extends StatelessWidget{
  const EventsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.week,
        firstDayOfWeek: 1,
        
        //monthViewSettings: const MonthViewSettings(showAgenda: true),
      ));
  }
}

