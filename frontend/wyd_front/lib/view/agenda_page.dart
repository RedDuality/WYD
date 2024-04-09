import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

import '../model/model.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCalendar(
      view: CalendarView.week,
      firstDayOfWeek: 1,
      dataSource: _getDataSource(),
      allowedViews: const [CalendarView.week, CalendarView.month],
      allowDragAndDrop: true,
      onTap: (details) => calendarTapped(details, context),
      //monthViewSettings: const MonthViewSettings(showAgenda: true),
    ));
  }
}

void calendarTapped(CalendarTapDetails details, BuildContext context) {
  if (details.targetElement == CalendarElement.appointment ||
      details.targetElement == CalendarElement.agenda) {
    final Appointment appointmentDetails = details.appointments![0];

    var subjectText = appointmentDetails.subject;
    var dateText = DateFormat('MMMM dd, yyyy')
        .format(appointmentDetails.startTime)
        .toString();
    var startTimeText =
        DateFormat('hh:mm a').format(appointmentDetails.startTime).toString();
    var endTimeText =
        DateFormat('hh:mm a').format(appointmentDetails.endTime).toString();
    var timeDetails = "";
    if (appointmentDetails.isAllDay) {
      timeDetails = 'All day';
    } else {
      timeDetails = '$startTimeText-$endTimeText';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(subjectText),
            content: SizedBox(
              height: 80,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: <Widget>[
                      Text(''),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(timeDetails,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15)),
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('close'))
            ],
          );
        });
  }
}

DataSource _getDataSource() {
  List<Appointment> appointments = <Appointment>[];
  List<CalendarResource> resources = <CalendarResource>[];
  appointments.add(MyEvent(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      isAllDay: false,
      subject: 'Meeting',
      color: Colors.blue,
      resourceIds: <Object>['0001'],
      startTimeZone: '',
      endTimeZone: ''));

  resources.add(
      CalendarResource(displayName: 'John', id: '0001', color: Colors.red));

  return DataSource(appointments, resources);
}
