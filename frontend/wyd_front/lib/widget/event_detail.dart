import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/widget/range_editor.dart';

class EventDetail extends StatefulWidget {
  final Event? event;
  final DateTime? date;
  const EventDetail({super.key, this.event, this.date});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  @override
  Widget build(BuildContext context) {
    final eventKey = GlobalKey<FormState>();
    var event = widget.event;

    String eventName = event != null ? event.title : 'Evento senza nome';
    String? description = event?.description;

    DateTime startDate =
        event != null ? event.startTime! : (widget.date ?? DateTime.now());
    
    DateTime endDate = event != null
        ? event.endTime!
        : (widget.date ?? DateTime.now()).add(const Duration(hours: 1));

    return Form(
      key: eventKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  style: const TextStyle(fontSize: 26),
                  initialValue: eventName,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    eventName = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Inserisci il nome dell\'evento',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 4), // Adjust this value
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                )),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Chiudi'),
                ),
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Dettagli"),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(fontSize: 14),
                      initialValue: description,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onChanged: (value) {
                        eventName = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'No description',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 4), // Adjust this value
                        isDense: true, // Ensures a more compact height
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                RangeEditor(
                  initialStartDate: startDate,
                  initialEndDate: endDate,
                  onDateChanged: (updatedDates) {
                    setState(() {
                      startDate = updatedDates['startDate']!;
                      endDate = updatedDates['endDate']!;
                    });
                  },
                )
              ],
            ),
          )),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salva'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
