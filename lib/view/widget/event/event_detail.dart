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

class EventDetail extends StatelessWidget {
  const EventDetail({super.key});

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

        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.lightBlue,
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
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
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                      )),
                      //if (currentEvent != null) Text(currentEvent.getConfirmTitle().trim()),
                      TextButton(
                        onPressed: () {
                          provider.close();
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
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
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
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  onChanged: (value) {
                                    provider.updateDescription(value);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'No description',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 4), // Adjust this value
                                    isDense:
                                        true, // Ensures a more compact height
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              RangeEditor(provider: provider),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!hasBeenChanged &&
                                        exists &&
                                        provider.confirmed) // Decline
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await EventService().decline(provider
                                              .getEventWithCurrentFields());
                                          provider.decline();
                                        },
                                        icon: Icon(Icons.event_busy),
                                        label: Row(
                                          children: [
                                            if (MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                200)
                                              Text('Decline',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      ),
                                    if (!hasBeenChanged &&
                                        exists &&
                                        !provider.confirmed) // Confirm
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await EventService().confirm(provider
                                              .getEventWithCurrentFields());
                                          provider.confirm();
                                        },
                                        icon: Icon(Icons.event_available),
                                        label: Row(
                                          children: [
                                            if (MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                200)
                                              Text('Confirm',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      ),
                                    if (exists && hasBeenChanged) // Update
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await _updateEvent(provider);
                                          if (context.mounted) {
                                            InformationService().showInfoSnackBar(
                                                context,
                                                "Evento aggiornato con successo");
                                          }
                                        },
                                        icon: Icon(Icons.update),
                                        label: Row(
                                          children: [
                                            if (MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                200)
                                              Text('Update',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          //Photos
                          if (exists)
                            const Divider(
                              color: Colors.grey,
                              thickness: 0.5,
                            ),
                          if (exists) 
                            BlobEditor(provider: provider),
                        ],
                      ),
                    ),
                  ),
                ),
                //Buttons
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!hasBeenChanged && exists) // Share
                    ElevatedButton.icon(
                      onPressed: () {
                        showCustomDialog(
                          context,
                          SharePage(
                              eventTitle: provider.title,
                              eventHash: provider.hash!),
                        );
                      },
                      icon: Icon(Icons.share),
                      label: Row(
                        children: [
                          if (MediaQuery.of(context).size.width > 400)
                            Text('Share', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (!hasBeenChanged && exists) // Send
                    ElevatedButton.icon(
                      onPressed: () async {
                        String? siteUrl = dotenv.env['SITE_URL'];
                        String fullUrl =
                            "$siteUrl#/shared?event=${provider.hash}";

                        if (kIsWeb) {
                          await Clipboard.setData(ClipboardData(text: fullUrl));

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            InformationService().showInfoSnackBar(
                                context, "Link copiato con successo");
                          }
                        } else {
                          // If running on mobile, use the share dialog
                          await Share.share(fullUrl);
                        }
                      },
                      icon: Icon(Icons.send),
                      label: Row(
                        children: [
                          if (MediaQuery.of(context).size.width > 400)
                            Text('Send', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  if (!exists) // Save
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _createEvent(provider);
                        if (context.mounted) {
                          InformationService().showInfoSnackBar(
                              context, "Evento creato con successo");
                        }
                      },
                      icon: Icon(Icons.save),
                      label: Row(
                        children: [
                          if (MediaQuery.of(context).size.width > 400)
                            Text('Save', style: TextStyle(fontSize: 18)),
                        ],
                      ),
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
