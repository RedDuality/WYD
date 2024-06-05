import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:wyd_front/state/private_events.dart';
import 'package:wyd_front/widget/groupsCheckBox.dart'; //DA VERIFICARE

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key, Key? agendakey});

  @override
  Widget build(BuildContext context) {
    var privateEvents = context.read<PrivateEvents>();

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
                  showGroupsDialog(context);
                },
                child: const Text('Condividi')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('close'),
            )
          ],
        );
      },
    );
  }
}

//SISTEMAZIONE PROVVISORIA
void showGroupsDialog(BuildContext context) {
  List<String> groups = ['Gruppo 1', 'Gruppo 2', 'Gruppo 3', 'Gruppo 4'];
  Map<String, bool> selectedGroups = {for (var group in groups) group: false};

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Seleziona gruppi'),
            content: SizedBox(
              height: 200,
              child: ListView(
                children: groups.map((group) {
                  return CheckboxListTile(
                    title: Text(group),
                    value: selectedGroups[group],
                    onChanged: (bool? value) {
                      setState(() {
                        selectedGroups[group] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  List<String> selected = selectedGroups.entries
                      .where((entry) => entry.value)
                      .map((entry) => entry.key)
                      .toList();
                  // Esegui l'azione desiderata con i gruppi selezionati
                  print('Gruppi selezionati: $selected');
                  Navigator.of(context).pop();
                },
                child: const Text('Condividi'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Chiudi'),
              ),
            ],
          );
        },
      );
    },
  );
}
