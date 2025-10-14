import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';
import 'package:wyd_front/view/events/eventEditor/confirmed_list.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/events/eventEditor/range_editor.dart';
import 'package:wyd_front/view/events/eventEditor/share_page.dart';
import 'package:wyd_front/view/widget/button/overlay_list_button.dart';

class EventViewEditor extends StatefulWidget {
  final Function(String) onEventCreated;
  const EventViewEditor({super.key, required this.onEventCreated});

  @override
  State<EventViewEditor> createState() => _EventViewEditorState();
}

class _EventViewEditorState extends State<EventViewEditor> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDescription(EventViewProvider provider) {
    provider.updateDescription(_descriptionController.text);
  }

  Future<void> _createEvent(EventViewProvider provider) async {
    Event createEvent = provider.getEventWithCurrentFields();
    Event newEvent = await EventViewService.create(createEvent);
    widget.onEventCreated(newEvent.eventHash);
    EventViewService.initialize(newEvent, null, newEvent.currentConfirmed());
  }

  Future<void> _updateEvent(EventViewProvider provider) async {
    var updateDto = provider.getUpdateDto();
    if (updateDto != null) await EventViewService.update(updateDto);
  }

  Future<void> _deleteEvent(EventViewProvider provider) async {
    Event? deleteEvent = await EventStorage().getEventByHash(provider.hash!);
    if (deleteEvent != null) {
      EventViewService.delete(deleteEvent).then(
        (value) {
          if (mounted) Navigator.of(context).pop();
        },
        onError: (error) =>
            {if (mounted) InformationService().showInfoPopup(context, "There was an error trying to delete the event")},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventViewProvider>(
      builder: (context, event, child) {
        bool hasBeenChanged = event.hasBeenChanged();
        bool exists = event.exists();
        bool isOwner = exists && event.isOwner();
        var isWideScreen = MediaQuery.of(context).size.width > 450;
        _descriptionController.text = event.description ?? "";

        var confirmTitle = "${event.getEventWithCurrentFields().getConfirmTitle()} Confirmed";
        var shared = event.totalProfiles > 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dettagli"),
                if (exists && isWideScreen && shared)
                  OverlayListButton(
                    title: confirmTitle,
                    child: ConfirmedList(provider: event),
                  ),
              ],
            ),
            if (exists && !isWideScreen && shared)
              Column(
                children: [
                  const SizedBox(height: 4),
                  OverlayListButton(
                    title: confirmTitle,
                    child: ConfirmedList(provider: event),
                  ),
                ],
              ),
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
                onEditingComplete: () {
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
            RangeEditor(provider: event),
            //Buttons
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!hasBeenChanged && exists) // Share
                    ElevatedButton(
                      onPressed: () {
                        showCustomDialog(
                          context,
                          SharePage(eventTitle: event.title, eventHash: event.hash!),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          MediaQuery.of(context).size.width > 450
                              ? Text('Invite', style: TextStyle(fontSize: 18))
                              : Container(),
                        ],
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (!hasBeenChanged && exists) // Send
                    ElevatedButton(
                      onPressed: () async {
                        String? siteUrl = dotenv.env['SITE_URL'];
                        String fullUrl = "$siteUrl#/shared?event=${event.hash}";

                        if (kIsWeb) {
                          await Clipboard.setData(ClipboardData(text: fullUrl));

                          if (context.mounted) {
                            InformationService().showInfoPopup(context, "Link copiato con successo");
                          }
                        } else {
                          // If running on mobile, use the share dialog
                          final result =
                              await SharePlus.instance.share(ShareParams(text: fullUrl, subject: event.title));
                          if (result == ShareResult.unavailable) {
                            debugPrint("It was not possible to share the event");
                          }
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send),
                          MediaQuery.of(context).size.width > 450
                              ? Text('Send', style: TextStyle(fontSize: 18))
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (!hasBeenChanged && exists && event.confirmed) // Decline
                    ElevatedButton(
                      onPressed: () async {
                        await EventViewService.decline(event.hash!);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_busy,
                            color: Colors.red,
                          ),
                          MediaQuery.of(context).size.width > 400
                              ? Text('Decline', style: TextStyle(color: Colors.red, fontSize: 18))
                              : Container(),
                        ],
                      ),
                    ),
                  if (!hasBeenChanged && exists && !event.confirmed) // Confirm
                    ElevatedButton(
                      onPressed: () async {
                        await EventViewService.confirm(event.hash!);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.event_available),
                          MediaQuery.of(context).size.width > 400
                              ? Text('Confirm', style: TextStyle(fontSize: 18))
                              : Container(),
                        ],
                      ),
                    ),
                  if (exists && hasBeenChanged) // Update
                    ElevatedButton(
                      onPressed: () async {
                        await _updateEvent(event);
                        if (context.mounted) {
                          InformationService().showInfoPopup(context, "Evento aggiornato con successo");
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.update),
                          if (MediaQuery.of(context).size.width > 400) Text('Update', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  if (!exists) // Save
                    ElevatedButton(
                      onPressed: () async {
                        await _createEvent(event);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.save),
                          if (MediaQuery.of(context).size.width > 400) Text('Save', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 5),
            if (exists && isOwner)
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        _deleteEvent(event);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          if (MediaQuery.of(context).size.width > 200)
                            Text(
                              'Delete',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
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
