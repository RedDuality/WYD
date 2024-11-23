import 'dart:math';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/state/user_provider.dart';

void showCreateEventDialog(
    BuildContext context, DateTime? date, bool? confirmed) {
      
  Future<DateTime?> showDatePickerDialog(context, currentValue) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      initialDate: currentValue ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
      );
      return DateTimeField.combine(date, time);
    } else {
      return currentValue;
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      String eventName = 'Evento senza nome';
      DateTime? startDate = date ?? DateTime.now();
      DateTime? endDate = startDate.add(const Duration(hours: 1));

      return AlertDialog(
        title: const Text('Inserisci i dati dell\'evento'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) {
                  eventName = value;
                },
              ),
              DateTimeField(
                initialValue: startDate,
                decoration: const InputDecoration(
                  labelText: 'Data e ora di inizio',
                ),
                format: DateFormat("yyyy-MM-dd HH:mm"),
                onChanged: (DateTime? value) {
                  if (value != null) {
                    startDate = value;
                    // Automatically update endDate if it's null or before new startDate
                    if (endDate == null || endDate!.isBefore(startDate!)) {
                      endDate = startDate!.add(const Duration(hours: 1));
                    }
                  }
                },
                onShowPicker: showDatePickerDialog,
              ),
              DateTimeField(
                initialValue: endDate,
                decoration: const InputDecoration(
                  labelText: 'Data e ora di Fine',
                ),
                format: DateFormat("yyyy-MM-dd HH:mm"),
                onChanged: (DateTime? value) {
                  endDate = value;
                },
                onShowPicker: showDatePickerDialog,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              // Ensure startDate is before endDate before creating the event
              if (startDate == null ||
                  endDate == null ||
                  startDate!.isAfter(endDate!)) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Errore'),
                    content: const Text(
                        'La data di inizio deve essere prima della data di fine.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }

              var generatedColor =
                  Colors.primaries[Random().nextInt(Colors.primaries.length)];

              Event event = Event(
                date: startDate!,
                startTime: startDate!,
                endTime: endDate!,
                title: eventName,
                color: generatedColor,
              );

              if (confirmed != null) {
                int mainProfileId =
                    context.read<UserProvider>().getMainProfileId();
                ProfileEvent profileEvent = ProfileEvent(
                    mainProfileId, EventRole.owner, confirmed, true);
                event.sharedWith.add(profileEvent);
              }



              // Call the createEvent method and await its completion
              await EventService().createEvent(context, event);

              // Close the loading dialog and the current one
              if (context.mounted) {
                Navigator.of(context).pop(); // Close the event creation dialog
              }
            },
            child: const Text('Salva'),
          ),
        ],
      );
    },
  );
}
