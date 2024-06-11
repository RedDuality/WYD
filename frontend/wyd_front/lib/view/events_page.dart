import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:wyd_front/service/test_service.dart';
import 'package:wyd_front/state/my_app_state.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var sharedEvents = context.read<MyAppState>().sharedEvents; //Da Modificare

    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: SfCalendar(
            view: CalendarView.week,
            firstDayOfWeek: 1,
            dataSource: sharedEvents,
            allowedViews: const [CalendarView.week, CalendarView.month],
            allowDragAndDrop: true,
            onTap: (details) => calendarTapped(details, context),
            //monthViewSettings: const MonthViewSettings(showAgenda: true),
          ),
        ),
        TextButton(
            onPressed: () {
              //String json = jsonEncode(sharedEvents.appointments![0]);
              TestService().ping().then((response) { debugPrint(response.body.toString()); });
            },
            child: const Align(
                alignment: Alignment.bottomCenter, child: Text('API TEST'))),
      ],
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
                  child: const Text('Confirm')),
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
