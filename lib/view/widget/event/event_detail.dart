import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/user_provider.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/event/blob_editor.dart';
import 'package:wyd_front/view/widget/event/range_editor.dart';
import 'package:wyd_front/view/widget/event/share_page.dart';

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

  void _onFieldChanged() {
    setState(() {
      hasBeenChanged = true;
    });
  }

  Future<void> _createEvent(BuildContext context) async {
    final dateRangeProvider =
        Provider.of<DateRangeProvider>(context, listen: false);
    final blobProvider = Provider.of<BlobProvider>(context, listen: false);

    Event createEvent = Event(
      date: dateRangeProvider.startDate,
      startTime: dateRangeProvider.startDate,
      endTime: dateRangeProvider.endDate,
      endDate: dateRangeProvider.endDate,
      title: eventTitle,
      description: description,
      newBlobs: blobProvider.newImages,
    );

    int mainProfileId = UserProvider().getCurrentProfileId();
    ProfileEvent profileEvent =
        ProfileEvent(mainProfileId, EventRole.owner, widget.confirmed, true);
    createEvent.sharedWith.add(profileEvent);

    Event newEvent = await EventService().create(createEvent);

    setState(() {
      hasBeenChanged = false;
      event = newEvent;
    });

    if (context.mounted) {
      InformationService()
          .showInfoSnackBar(context, "Evento creato con successo");
    }
  }

  Future<void> _updateEvent(BuildContext context) async {
    final dateRangeProvider =
        Provider.of<DateRangeProvider>(context, listen: false);
    final blobProvider = Provider.of<BlobProvider>(context, listen: false);

    Event updatesEvent = event!.copy(
        date: dateRangeProvider.startDate,
        startTime: dateRangeProvider.startDate,
        endTime: dateRangeProvider.endDate,
        endDate: dateRangeProvider.endDate,
        title: eventTitle,
        description: description,
        newBlobs: blobProvider.newImages);

    var updatedEvent = await EventService().update(updatesEvent);

    blobProvider.updateImages(updatedEvent.images);
    setState(() {
      hasBeenChanged = false;
      event = updatedEvent;
    });
    if (context.mounted) {
      InformationService()
          .showInfoSnackBar(context, "Evento aggiornato con successo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              DateRangeProvider(startDate, endDate, onChanged: _onFieldChanged),
        ),
        ChangeNotifierProvider(
          create: (_) => BlobProvider(event != null ? event!.hash : "",
              event != null ? event!.images : [],
              onChanged: _onFieldChanged),
        ),
      ],
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 4), // Adjust this value
                      isDense: true, // Ensures a more compact height
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  )),
                  if (event != null) Text(event!.getConfirmTitle().trim()),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red, // Sets the icon color to red
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 36, // Adjusts the size of the "X" icon
                    ),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
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
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const RangeEditor(),
                    const SizedBox(height: 10),
                    const BlobEditor(),
                  ],
                ),
              ),
            ),
            //Buttons
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!hasBeenChanged && event != null) //Share
                    TextButton(
                        onPressed: () {
                          showCustomDialog(context, SharePage(event: event!));
                        },
                        child: const Text('Condividi')),
                  if (!hasBeenChanged && event != null) //Share
                    TextButton(
                      onPressed: () async {
                        String? siteUrl = dotenv.env['SITE_URL'];
                        String fullUrl =
                            "$siteUrl#/shared?event=${event!.hash}";

                        if (kIsWeb) {
                          await Clipboard.setData(ClipboardData(text: fullUrl));

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            InformationService().showInfoSnackBar(
                                context, "Link copiato con successo");
                          }
                        } else {
                          // If running on mobile, use the share dialog
                          await Share.share(fullUrl);
                        }
                      },
                      child: const Text('Invia'),
                    ),
                  if (!hasBeenChanged &&
                      event != null &&
                      event!.confirmed()) //Decline
                    TextButton(
                      onPressed: () async {
                        var newEvent = await EventService().decline(event!);
                        if (newEvent != null) {
                          setState(() {
                            event = newEvent;
                          });
                        }
                      },
                      child: const Text('Decline'),
                    ),
                  if (!hasBeenChanged &&
                      event != null &&
                      !event!.confirmed()) //Confirm
                    TextButton(
                      onPressed: () async {
                        var newEvent = await EventService().confirm(event!);
                        if (newEvent != null) {
                          setState(() {
                            event = newEvent;
                          });
                        }
                      },
                      child: const Text('Confirm'),
                    ),
                  if (event != null && hasBeenChanged) //Update
                    TextButton(
                      onPressed: () async {
                        await _updateEvent(context);
                      },
                      child: const Text('Aggiorna'),
                    ),
                  if (event == null) //Save
                    TextButton(
                      onPressed: () async {
                        await _createEvent(context);
                      },
                      child: const Text('Crea'),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
