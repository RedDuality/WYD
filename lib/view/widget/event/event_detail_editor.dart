import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/detail_provider.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/event/range_editor.dart';
import 'package:wyd_front/view/widget/event/share_page.dart';

class EventDetailEditor extends StatefulWidget {
  const EventDetailEditor({super.key});

  @override
  State<EventDetailEditor> createState() => _EventDetailEditorState();
}

class _EventDetailEditorState extends State<EventDetailEditor> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDescription(DetailProvider provider) {
    provider.updateDescription(_descriptionController.text);
  }

  Future<void> _createEvent(DetailProvider provider) async {
    Event createEvent = provider.getEventWithCurrentFields();
    Event newEvent = await EventService().create(createEvent);
    EventService().initializeDetails(newEvent, null, newEvent.confirmed());
  }

  Future<void> _updateEvent(DetailProvider provider) async {
    Event updatesEvent = provider.getEventWithCurrentFields();

    await EventService().update(updatesEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailProvider>(
      builder: (context, event, child) {
        bool hasBeenChanged = event.hasBeenChanged();
        bool exists = event.exists();

        _descriptionController.text = event.description ?? "";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("Dettagli"),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style: const TextStyle(fontSize: 14),
                controller: _descriptionController,
                onTapOutside: (e) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _updateDescription(event);
                },
                onFieldSubmitted: (value) {
                  _updateDescription(event);
                },
                decoration: const InputDecoration(
                  hintText: 'No description',
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  isDense: true, // Ensures a more compact height
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 10),
            RangeEditor(provider: event),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!hasBeenChanged && exists) // Share
                    ElevatedButton.icon(
                      onPressed: () {
                        showCustomDialog(
                          context,
                          SharePage(
                              eventTitle: event.title, eventHash: event.hash!),
                        );
                      },
                      icon: Icon(Icons.share),
                      label: Row(
                        children: [
                          if (MediaQuery.of(context).size.width > 450)
                            Text('Share', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (!hasBeenChanged && exists) // Send
                    ElevatedButton.icon(
                      onPressed: () async {
                        String? siteUrl = dotenv.env['SITE_URL'];
                        String fullUrl = "$siteUrl#/shared?event=${event.hash}";

                        if (kIsWeb) {
                          await Clipboard.setData(ClipboardData(text: fullUrl));

                          if (context.mounted) {
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
                          if (MediaQuery.of(context).size.width > 450)
                            Text('Send', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (!hasBeenChanged && exists && event.confirmed) // Decline
                    ElevatedButton.icon(
                      onPressed: () async {
                        var currentEvent = event.getEventWithCurrentFields();
                        await EventService().decline(currentEvent);
                      },
                      icon: Icon(Icons.event_busy),
                      label: Row(
                        children: [
                          if (MediaQuery.of(context).size.width > 400)
                            Text('Decline', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  if (!hasBeenChanged && exists && !event.confirmed) // Confirm
                    ElevatedButton.icon(
                      onPressed: () async {
                        var currentEvent = event.getEventWithCurrentFields();
                        await EventService().confirm(currentEvent);
                      },
                      icon: Icon(Icons.event_available),
                      label: Row(
                        children: [
                          if (MediaQuery.of(context).size.width > 300)
                            Text('Confirm', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  if (exists && hasBeenChanged) // Update
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _updateEvent(event);
                        if (context.mounted) {
                          InformationService().showInfoSnackBar(
                              context, "Evento aggiornato con successo");
                        }
                      },
                      icon: Icon(Icons.update),
                      label: Row(
                        children: [
                          if (MediaQuery.of(context).size.width > 200)
                            Text('Update', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  if (!exists) // Save
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _createEvent(event);
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
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
