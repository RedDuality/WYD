import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/event_detail_provider.dart';
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EventDetailProvider>(context, listen: false);
      provider.initialize(widget.initialEvent, widget.date, widget.confirmed);
    });
  }

  Future<void> _createEvent(EventDetailProvider provider) async {
    Event createEvent = provider.getEventWithCurrentFields();
    Event newEvent = await EventService().create(createEvent);
    provider.updateEvent(newEvent);
  }

  Future<void> _updateEvent(EventDetailProvider provider) async {
    Event updatesEvent = provider.getEventWithCurrentFields();

    var updatedEvent = await EventService().update(updatesEvent);

    provider.updateEvent(updatedEvent);
    provider.cleadNewImages();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventDetailProvider>(
      builder: (context, provider, child) {
        bool hasBeenChanged = provider.hasBeenChanged();
        bool exists = provider.exists();

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    style: const TextStyle(fontSize: 26),
                    initialValue: provider.title,
                    onTapOutside: (e) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onChanged: (value) {
                      provider.updateTitle(value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Inserisci il nome dell\'evento',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 4), // Adjust this value
                      isDense: true, // Ensures a more compact height
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  )),
                  //if (currentEvent != null) Text(currentEvent.getConfirmTitle().trim()),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Colors.grey, // Sets the icon color to red
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 36, // Adjusts the size of the "X" icon
                    ),
                  ),
                ],
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
                              initialValue: provider.description,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              onChanged: (value) {
                                provider.updateDescription(value);
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
                          ),
                          const SizedBox(height: 10),
                          RangeEditor(provider: provider),
                          const SizedBox(height: 10),
                          if (exists) BlobEditor(provider: provider),
                        ],
                      ),
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
                    if (!hasBeenChanged && exists) //Share
                      TextButton(
                          onPressed: () {
                            showCustomDialog(
                                context,
                                SharePage(
                                    eventTitle: provider.title,
                                    eventHash: provider.hash!));
                          },
                          child: const Text('Condividi')),
                    if (!hasBeenChanged && exists) //Share
                      TextButton(
                        onPressed: () async {
                          String? siteUrl = dotenv.env['SITE_URL'];
                          String fullUrl =
                              "$siteUrl#/shared?event=${provider.hash}";

                          if (kIsWeb) {
                            await Clipboard.setData(
                                ClipboardData(text: fullUrl));

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
                        exists &&
                        provider.confirmed) //Decline
                      TextButton(
                        onPressed: () async {
                          await EventService()
                              .decline(provider.getEventWithCurrentFields());
                          provider.decline();
                        },
                        child: const Text('Decline'),
                      ),
                    if (!hasBeenChanged &&
                        exists &&
                        !provider.confirmed) //Confirm
                      TextButton(
                        onPressed: () async {
                          await EventService()
                              .confirm(provider.getEventWithCurrentFields());
                          provider.confirm();
                        },
                        child: const Text('Confirm'),
                      ),
                    if (exists && hasBeenChanged) //Update
                      TextButton(
                        onPressed: () async {
                          await _updateEvent(provider);
                          if (context.mounted) {
                            InformationService().showInfoSnackBar(
                                context, "Evento aggiornato con successo");
                          }
                        },
                        child: const Text('Aggiorna'),
                      ),
                    if (!exists) //Save
                      TextButton(
                        onPressed: () async {
                          await _createEvent(provider);
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
          ),
        );
      },
    );
  }
}
