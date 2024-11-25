import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/service/information_service.dart';
import 'package:wyd_front/state/user_provider.dart';
import 'package:wyd_front/widget/dialog/groups_dialog.dart';
import 'package:wyd_front/widget/range_editor.dart';

class EventDetail extends StatefulWidget {
  final Event? initialEvent;
  final DateTime? date;
  final bool confirmed;

  const EventDetail(
      {super.key, this.initialEvent, this.date, required this.confirmed});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  late bool hasBeenChanged;
  late Event? event;

  late String eventTitle;
  late String? description;

  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    hasBeenChanged = false;

    event = widget.initialEvent;

    eventTitle = event != null ? event!.title : 'Evento senza nome';
    description = event?.description;

    startDate =
        event != null ? event!.startTime! : (widget.date ?? DateTime.now());

    endDate = event != null
        ? event!.endTime!
        : (widget.date ?? DateTime.now()).add(const Duration(hours: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                initialValue: eventTitle,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onChanged: (value) {
                  setState(() {
                    hasBeenChanged = true;
                    eventTitle = value;
                  });
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
                      setState(() {
                        hasBeenChanged = true;
                        description = value;
                      });
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
                    hasBeenChanged = true;
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
              if (!hasBeenChanged && event != null)
                TextButton(
                    onPressed: () {
                      showGroupsDialog(context, event!);
                    },
                    child: const Text('Condividi')),
              if (!hasBeenChanged && event != null && event!.confirmed())
                TextButton(
                  onPressed: () {
                    EventService().decline(event!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Decline'),
                ),
              if (!hasBeenChanged && event != null && !event!.confirmed())
                TextButton(
                  onPressed: () {
                    EventService().confirm(event!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirm'),
                ),
              if (event != null && hasBeenChanged)
                TextButton(
                  onPressed: () async {

                    Event updateEvent = event!.copy(title: eventTitle, date: startDate, startTime: startDate, endTime: endDate, description: description);

                    await EventService().update(event!, updateEvent);
                    setState(() {
                      hasBeenChanged = false;
                      event = updateEvent;
                    });
                    if (context.mounted) {
                      InformationService().showInfoSnackBar(
                          context, "Evento aggiornato con successo");
                    }
                  },
                  child: const Text('Aggiorna'),
                ),
              if (/*creating a new*/ event == null)
                TextButton(
                  onPressed: () async {
                    Event createEvent = Event(
                      date: startDate,
                      startTime: startDate,
                      endTime: endDate,
                      title: eventTitle,
                      description: description,
                    );

                    int mainProfileId = UserProvider().getMainProfileId();
                    ProfileEvent profileEvent = ProfileEvent(
                        mainProfileId, EventRole.owner, widget.confirmed, true);
                    createEvent.sharedWith.add(profileEvent);

                    Event newEvent = await EventService().create(createEvent);
                    setState(() {
                      hasBeenChanged = false;
                      event = newEvent;
                    });

                    if (context.mounted) {
                      InformationService().showInfoSnackBar(
                          context, "Evento creato con successo");
                    }
                  },
                  child: const Text('Crea'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
