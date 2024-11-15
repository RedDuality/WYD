import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:wyd_front/service/my_event_service.dart';
import 'package:wyd_front/model/my_event.dart';
import 'package:wyd_front/state/events_provider.dart';
import 'package:wyd_front/widget/dialog/groups_dialog.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    var privateEvents = context.watch<EventsProvider>().privateEvents;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SfCalendar(
              view: CalendarView.week,
              firstDayOfWeek: 1,
              dataSource: privateEvents,
              allowedViews: const [CalendarView.week, CalendarView.month],
              allowDragAndDrop: true,
              onTap: (details) => calendarTapped(details, context),
            ),
          ),
        ],
      ),
    );
  }
}

void calendarTapped(CalendarTapDetails details, BuildContext context) {
  if (details.targetElement == CalendarElement.appointment ||
      details.targetElement == CalendarElement.agenda) {
    final MyEvent appointmentDetails = details.appointments![0];

    var subjectText = appointmentDetails.subject;

    var dateText = DateFormat('MMMM dd, yyyy')
        .format(appointmentDetails.startTime)
        .toString();
    var startTimeText =
        DateFormat('hh:mm a').format(appointmentDetails.startTime).toString();
    var endTimeText =
        DateFormat('hh:mm a').format(appointmentDetails.endTime).toString();
    var timeDetails = appointmentDetails.isAllDay
        ? 'All day'
        : '$startTimeText - $endTimeText';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(subjectText),
          content: SizedBox(
            height: 100, // Altezza modificata per prevenire errori di rendering
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dateText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  timeDetails,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  //MyEventService(context: context).decline(context, appointmentDetails);
                  Navigator.of(context).pop();
                },
                child: const Text('Disdici')),
            TextButton(
                onPressed: () {
                  showGroupsDialog(context, appointmentDetails);
                },
                child: const Text('Condividi')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Chiudi'),
            )
          ],
        );
      },
    );
  }
}
