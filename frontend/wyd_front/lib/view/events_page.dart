import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:wyd_front/controller/my_event_controller.dart';
import 'package:wyd_front/model/events_data_source.dart';
import 'package:wyd_front/model/my_event.dart';
import 'package:wyd_front/service/test_service.dart';
import 'package:wyd_front/state/events_provider.dart';
class EventsPage extends StatelessWidget {
  final String uri;

  const EventsPage({super.key, this.uri = ""});

  @override
  Widget build(BuildContext context) {
    var privateEvents = context.watch<EventsProvider>().privateEvents;
    var sharedEvents = context.watch<EventsProvider>().sharedEvents;

    var eventHash = Uri.dataFromString(uri).queryParameters['event'];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (eventHash != null) {
        final event = await MyEventController().retrieveFromHash(eventHash);

        if (event != null && context.mounted) {
          var dateText =
              DateFormat('MMMM dd, yyyy').format(event.startTime).toString();
          var startTimeText =
              DateFormat('hh:mm a').format(event.startTime).toString();
          var endTimeText =
              DateFormat('hh:mm a').format(event.endTime).toString();
          var timeDetails =
              event.isAllDay ? 'All day' : '$startTimeText - $endTimeText';

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(event.subject),
                content: SizedBox(
                  height:
                      100, // Altezza modificata per prevenire errori di rendering
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
                      _addEvent(privateEvents, sharedEvents, event, true);
                      Navigator.of(context).pop();
                    },
                    child: const Text('I\'ll be there!'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addEvent(privateEvents, sharedEvents, event, false);
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Dismiss'),
                  ),
                ],
              );
            },
          );
        }
      }
    });

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
              TestService().ping().then((response) {
                debugPrint(response.body.toString());
              });
            },
            child: const Align(
                alignment: Alignment.bottomCenter, child: Text('API TEST'))),
      ],
    ));
  }
}

Future<void> _addEvent(
    EventsDataSource privateEvents, EventsDataSource sharedEvents, MyEvent event, bool confirmed) async {
  if (confirmed) {
    if (sharedEvents.appointments!.contains(event)) {
      bool saved = await MyEventController().confirmFromHash(event, confirmed);
      if (saved) {
        sharedEvents.removeAppointment(event);
        privateEvents.addAppointement(event);
      }
    } else if (!privateEvents.appointments!.contains(event)) {
      bool saved = await MyEventController().confirmFromHash(event, confirmed);
      if (saved) {
        privateEvents.addAppointement(event);
      }
    }
  } else {
    if (!privateEvents.appointments!.contains(event) &&
        !sharedEvents.appointments!.contains(event)) {
      bool saved = await MyEventController().confirmFromHash(event, confirmed);
      if (saved) {
        sharedEvents.addAppointement(event);
      }
    }
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
                    MyEventController().confirm(context, appointmentDetails);
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
