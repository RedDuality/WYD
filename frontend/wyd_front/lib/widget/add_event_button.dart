import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/model.dart';
import 'package:wyd_front/state/private_events.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class AddEventButton extends StatelessWidget {
  const AddEventButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String eventName = 'Evento senza nome';
            DateTime? startDate;
            DateTime? endDate;
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
                      decoration: const InputDecoration(
                        labelText: 'Data e ora di inizio',
                      ),
                      format: DateFormat("yyyy-MM-dd HH:mm"),
                      onChanged: (DateTime? value) {
                        startDate = value;
                      },
                      onShowPicker: showDatePickerDialog,
                    ),
                    DateTimeField(
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
                  onPressed: () {
                    MyEvent newEvent = MyEvent(
                      startTime: startDate ?? DateTime.now(),
                      endTime: endDate ??
                          DateTime.now().add(const Duration(hours: 2)),
                      subject: eventName,
                      color: Colors.blue,
                    );

                    var privateEvents = context.read<PrivateEvents>();
                    privateEvents.addAppointement(newEvent);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
      label: const Text('Aggiungi Evento'),
      icon: const Icon(Icons.add),
    );
  }

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
}