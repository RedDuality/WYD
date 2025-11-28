import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wyd_front/API/Event/create_event_request_dto.dart';
import 'package:wyd_front/API/Event/update_event_request_dto.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/service/event/event_actions_service.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/event/events_cache.dart';
import 'package:wyd_front/state/event/event_details_cache.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_cache.dart';
import 'package:wyd_front/view/events/eventEditor/confirmed_list.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/events/eventEditor/range_editor.dart';
import 'package:wyd_front/view/events/eventEditor/share_page.dart';
import 'package:wyd_front/view/widget/button/overlay_list_button.dart';

class EventViewEditor extends StatefulWidget {
  final String? eventId;
  final DateTime? date;
  final TextEditingController titleController;
  final Function(String) onEventCreated;

  const EventViewEditor({
    super.key,
    required this.eventId,
    this.date,
    required this.titleController,
    required this.onEventCreated,
  });

  @override
  State<EventViewEditor> createState() => _EventViewEditorState();
}

class _EventViewEditorState extends State<EventViewEditor> {
  Event? originalEvent;
  late bool exists;

  late DetailedProfileEventsCache _profileEventsCache;

  final _descriptionController = TextEditingController();
  late VoidCallback _titleListener;

  late DateTime startTime;
  late DateTime endTime;

  bool shared = false;
  int totalConfirmed = 1;
  int totalProfiles = 1;

  String initialDescription = '';

  var isBeingChanged = false;

  @override
  void initState() {
    super.initState();

    // Use read here, not select/watch
    final provider = context.read<EventsCache>();
    originalEvent = widget.eventId != null ? provider.get(widget.eventId!) : null;

    exists = originalEvent != null;
    startTime = originalEvent?.startTime ?? (widget.date ?? DateTime.now());
    endTime = originalEvent?.endTime ?? (widget.date ?? DateTime.now()).add(const Duration(hours: 1));
    totalConfirmed = originalEvent?.totalConfirmed ?? 1;
    totalProfiles = originalEvent?.totalProfiles ?? 1;

    if (exists) {
      var details = EventDetailsCache().get(originalEvent!.id);
      if (details != null) {
        initialDescription = details.description;
      }
      shared = originalEvent!.totalProfiles > 1;
    }

    _descriptionController.text = initialDescription;

    _titleListener = () {
      _checkChanges();
    };

    _descriptionController.addListener(() {
      _checkChanges();
    });

    widget.titleController.addListener(_titleListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileEventsCache = Provider.of<DetailedProfileEventsCache>(context, listen: false);
  }

  void setDates(DateTime startTime, DateTime endTime) {
    setState(() {
      this.startTime = startTime;
      this.endTime = endTime;
    });
    _checkChanges();
  }

  void _checkChanges() {
    if (originalEvent == null) return;

    final titleChanged = originalEvent!.title.trim() != widget.titleController.text.trim();
    final descriptionChanged = initialDescription.trim() != _descriptionController.text.trim();
    final startTimeChanged = originalEvent!.startTime != startTime;
    final endTimeChanged = originalEvent!.endTime != endTime;

    final changed = startTimeChanged || endTimeChanged || titleChanged || descriptionChanged;
    if (changed != isBeingChanged) {
      setState(() {
        isBeingChanged = changed;
      });
    }
  }

  @override
  void dispose() {
    widget.titleController.removeListener(_titleListener);
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    final createdEvent = _getCreateDto();
    final newEventId = await EventActionsService.create(createdEvent);
    widget.onEventCreated(newEventId);
  }

  CreateEventRequestDto _getCreateDto() {
    return CreateEventRequestDto(
      title: widget.titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<void> _updateEvent() async {
    final updateDto = _getUpdateDto();
    if (updateDto != null) {
      await EventActionsService.update(updateDto);
      initialDescription = _descriptionController.text.trim();
    }
  }

  UpdateEventRequestDto? _getUpdateDto() {
    if (!isBeingChanged || originalEvent == null) return null;

    return UpdateEventRequestDto(
      eventId: originalEvent!.id,
      title:
          widget.titleController.text.trim() != originalEvent!.title.trim() ? widget.titleController.text.trim() : null,
      description:
          _descriptionController.text.trim() != initialDescription.trim() ? _descriptionController.text.trim() : null,
      startTime: startTime != originalEvent!.startTime ? startTime : null,
      endTime: endTime != originalEvent!.endTime ? endTime : null,
    );
  }

  Future<void> _deleteEvent() async {
    EventActionsService.delete(originalEvent!.id).then(
      (value) {
        if (mounted) Navigator.of(context).pop();
      },
      onError: (error) =>
          {if (mounted) InformationService().showInfoPopup(context, "There was an error trying to delete the event")},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Select only the specific event from provider
    originalEvent = context.select<EventsCache, Event?>(
      (provider) => widget.eventId != null ? provider.get(widget.eventId!) : null,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkChanges();
    });

    //var isWideScreen = MediaQuery.of(context).size.width > 450;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exists && shared)
              OverlayListButton(
                title: "${originalEvent!.totalConfirmed} / ${originalEvent!.totalProfiles} confirmed",
                child: ConfirmedList(eventId: originalEvent!.id),
              ),

            RangeEditor(
              startTime: startTime,
              endTime: endTime,
              onDateChanged: setDates,
            ),

            const Text("Dettagli"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style: const TextStyle(fontSize: 14),
                controller: _descriptionController,
                onChanged: (value) => _checkChanges(),
                decoration: const InputDecoration(
                  hintText: 'No description',
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  isDense: true, // Ensures a more compact height
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),

            const SizedBox(
              height: 5,
            ),
            //Buttons
            _buttons(context),
          ],
        ),
        if (exists && !isBeingChanged && _profileEventsCache.isOwner(originalEvent!.id))
          Positioned(
            top: 0,
            right: 0,
            child: _buildMenuButton(),
          ),
      ],
    );
  }

  Widget _buttons(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (exists && !isBeingChanged) // Share
                ElevatedButton(
                  onPressed: () {
                    showCustomDialog(
                      context,
                      SharePage(eventTitle: originalEvent!.title, eventId: originalEvent!.id),
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
              if (exists && !isBeingChanged) // Send
                ElevatedButton(
                  onPressed: () async {
                    String? siteUrl = dotenv.env['SITE_URL'];
                    String fullUrl = "$siteUrl/#/share?event=${originalEvent!.id}";

                    if (kIsWeb) {
                      await Clipboard.setData(ClipboardData(text: fullUrl));

                      if (context.mounted) {
                        InformationService().showInfoPopup(context, "Link copiato con successo");
                      }
                    } else {
                      // If running on mobile, use the share dialog
                      final result =
                          await SharePlus.instance.share(ShareParams(text: fullUrl, subject: originalEvent!.title));
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
              if (exists && !isBeingChanged && _profileEventsCache.currentConfirmed(originalEvent!.id)) // Decline
                ElevatedButton(
                  onPressed: () async {
                    await EventActionsService.decline(originalEvent!.id);
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
              if (exists && !isBeingChanged && !_profileEventsCache.currentConfirmed(originalEvent!.id)) // Confirm
                ElevatedButton(
                  onPressed: () async {
                    await EventActionsService.confirm(originalEvent!.id);
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
              if (exists && isBeingChanged) // Update
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
        //if (exists && !isBeingChanged && _profileEventsCache.isOwner(originalEvent!.id)) deleteButton(),
      ],
    );
  }

  Widget deleteButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              _deleteEvent();
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
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      splashRadius: 0.5,
      //constraints: BoxConstraints.tightFor(width: 30, height: 30),
      icon: const Icon(Icons.more_vert, size: 20.0),
      offset: const Offset(-10,40),
      onSelected: (String result) {
        // Handle menu item selection (e.g., Delete, Share, etc.)
        debugPrint('Menu option selected: $result');
        //_deleteEvent();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          height: 32.5,
          value: 'Delete',
          child: Text('Delete'),
        ),
        // Add more menu items here
      ],
    );
  }
}
