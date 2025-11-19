import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wyd_front/API/Event/update_event_request_dto.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';
import 'package:wyd_front/view/events/eventEditor/confirmed_list.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/events/eventEditor/range_editor.dart';
import 'package:wyd_front/view/events/eventEditor/share_page.dart';
import 'package:wyd_front/view/widget/button/overlay_list_button.dart';

class EventViewEditor extends StatefulWidget {
  final Event? event;
  final DateTime? date;
  final TextEditingController titleController;
  final Function(String) onEventCreated;

  const EventViewEditor({
    super.key,
    required this.event,
    this.date,
    required this.titleController,
    required this.onEventCreated,
  });

  @override
  State<EventViewEditor> createState() => _EventViewEditorState();
}

class _EventViewEditorState extends State<EventViewEditor> {
  late bool exists;
  bool shared = false;

  final _descriptionController = TextEditingController();
  late VoidCallback _titleListener;

  late DateTime startTime;
  late DateTime endTime;
  int totalConfirmed = 1;
  int totalProfiles = 1;

  String initialDescription = '';

  var hasBeenChanged = false;

  @override
  void initState() {
    super.initState();
    exists = widget.event != null;

    startTime = widget.event?.startTime ?? (widget.date ?? DateTime.now());
    endTime = widget.event?.endTime ?? (widget.date ?? DateTime.now()).add(const Duration(hours: 1));
    totalConfirmed = widget.event?.totalConfirmed ?? 1;
    totalProfiles = widget.event?.totalProfiles ?? 1;
    if (exists) {
      var details = EventDetailsStorage().get(widget.event!.eventHash);
      if (details != null) {
        initialDescription = details.description;
      }

      shared = widget.event!.totalProfiles > 1;
    }

    _descriptionController.text = initialDescription;

    _titleListener = () {
      var changed = _checkChanges();
      if (changed != hasBeenChanged) {
        setState(() {
          hasBeenChanged = changed;
        });
      }
    };

    _descriptionController.addListener(() {
      setState(() {
        hasBeenChanged = _checkChanges();
      });
    });

    widget.titleController.addListener(_titleListener);
  }

  void setDates(DateTime startTime, DateTime endTime) {
    setState(() {
      this.startTime = startTime;
      this.endTime = endTime;

      hasBeenChanged = _checkChanges();
    });
  }

  bool _checkChanges() {
    if (widget.event == null) return false;
    var titlechanged = widget.event!.title.trim() != widget.titleController.text.trim();
    var descriptionChanged = initialDescription.trim() != _descriptionController.text.trim();
    var startTimeChanged = widget.event!.startTime != startTime;
    var endTimeChanged = widget.event!.endTime != endTime;

    // debugPrint("$titlechanged, $descriptionChanged, $startTimeChanged, $endTimeChanged");

    return startTimeChanged || endTimeChanged || titlechanged || descriptionChanged;
  }

  @override
  void dispose() {
    widget.titleController.removeListener(_titleListener);
    _descriptionController.dispose();
    super.dispose();
  }

  Event _getEventWithCurrentFields() {
    Event event = Event(
      eventHash: widget.event != null ? widget.event!.eventHash : "",
      date: startTime,
      startTime: startTime,
      endTime: endTime,
      endDate: endTime,
      updatedAt: DateTime.now(),
      title: widget.titleController.text.trim(),
      description: _descriptionController.text.trim(),
      totalConfirmed: totalConfirmed,
      totalProfiles: totalProfiles,
      currentConfirmed: widget.event != null ? widget.event!.currentConfirmed : true,
    );

    return event;
  }

  Future<void> _createEvent() async {
    Event createdEvent = _getEventWithCurrentFields();
    Event newEvent = await EventViewService.create(createdEvent);
    widget.onEventCreated(newEvent.eventHash);
  }

  UpdateEventRequestDto? _getUpdateDto() {
    if (!hasBeenChanged || widget.event == null) return null;
    UpdateEventRequestDto updateDto = UpdateEventRequestDto(
      eventHash: widget.event!.eventHash,
      title:
          widget.titleController.text.trim() != widget.event!.title.trim() ? widget.titleController.text.trim() : null,
      description:
          _descriptionController.text.trim() != initialDescription.trim() ? _descriptionController.text.trim() : null,
      startTime: startTime != widget.event!.startTime ? startTime : null,
      endTime: endTime != widget.event!.endTime ? endTime : null,
    );
    return updateDto;
  }

  Future<void> _updateEvent() async {
    var updateDto = _getUpdateDto();
    if (updateDto != null) await EventViewService.update(updateDto);
    initialDescription = _descriptionController.text.trim();
  }

  /*
  Future<void> _deleteEvent(String eventHash) async {
    EventViewService.delete(eventHash).then(
      (value) {
        if (mounted) Navigator.of(context).pop();
      },
      onError: (error) =>
          {if (mounted) InformationService().showInfoPopup(context, "There was an error trying to delete the event")},
    );
  }*/

  @override
  Widget build(BuildContext context) {
    hasBeenChanged = _checkChanges();
    var isWideScreen = MediaQuery.of(context).size.width > 450;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dettagli"),
            if (exists && shared && isWideScreen)
              OverlayListButton(
                title: "${widget.event!.getConfirmTitle()} Confirmed",
                child: ConfirmedList(eventHash: widget.event!.eventHash),
              ),
          ],
        ),
        if (exists && shared && !isWideScreen)
          Column(
            children: [
              const SizedBox(height: 4),
              OverlayListButton(
                title: "${widget.event!.getConfirmTitle()} Confirmed",
                child: ConfirmedList(eventHash: widget.event!.eventHash),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            style: const TextStyle(fontSize: 14),
            controller: _descriptionController,
            onChanged: (value) => setState(() {
              hasBeenChanged = _checkChanges();
            }),
            decoration: const InputDecoration(
              hintText: 'No description',
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              isDense: true, // Ensures a more compact height
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
        ),
        RangeEditor(
          startTime: startTime,
          endTime: endTime,
          onDateChanged: setDates,
        ),
        //Buttons
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (exists && !hasBeenChanged) // Share
                ElevatedButton(
                  onPressed: () {
                    showCustomDialog(
                      context,
                      SharePage(eventTitle: widget.event!.title, eventHash: widget.event!.eventHash),
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
              if (exists && !hasBeenChanged) // Send
                ElevatedButton(
                  onPressed: () async {
                    String? siteUrl = dotenv.env['SITE_URL'];
                    String fullUrl = "$siteUrl/#/share?event=${widget.event!.eventHash}";

                    if (kIsWeb) {
                      await Clipboard.setData(ClipboardData(text: fullUrl));

                      if (context.mounted) {
                        InformationService().showInfoPopup(context, "Link copiato con successo");
                      }
                    } else {
                      // If running on mobile, use the share dialog
                      final result =
                          await SharePlus.instance.share(ShareParams(text: fullUrl, subject: widget.event!.title));
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
              if (exists && !hasBeenChanged && widget.event!.currentConfirmed) // Decline
                ElevatedButton(
                  onPressed: () async {
                    await EventViewService.decline(widget.event!.eventHash);
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
              if (exists && !hasBeenChanged && !widget.event!.currentConfirmed) // Confirm
                ElevatedButton(
                  onPressed: () async {
                    await EventViewService.confirm(widget.event!.eventHash);
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
                    await _updateEvent();
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
                    await _createEvent();
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
        /*
        if (exists && widget.event!.isOwner())
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _deleteEvent(widget.event!.eventHash);
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
          ),*/
      ],
    );
  }
}
