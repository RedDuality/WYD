import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/range_controller.dart';
import 'package:wyd_front/state/event/current_events_provider.dart';
import 'package:wyd_front/state/util/uri_service.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/events/event_tile.dart';
import 'package:wyd_front/view/events/eventEditor/event_view.dart';
import 'package:wyd_front/view/widget/header.dart';
import 'package:wyd_front/view/widget/util/add_event_button.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late RangeController rangeController;

  bool _private = true;

  @override
  void initState() {
    super.initState();

    rangeController = RangeController(DateTime.now(), 7);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventsController = Provider.of<CurrentEventsProvider>(context, listen: false);
      eventsController.initialize(rangeController, _private);
      _checkAndShowLinkEvent(context);
    });
  }

  Future<void> _checkAndShowLinkEvent(BuildContext context) async {
    final uri = await UriService.getUri();
    if (uri.isNotEmpty) {
      final destination = uri.split('?').first.replaceAll('/', '');
      if (destination == 'share') {
        var eventHash = Uri.dataFromString(uri).queryParameters['event'];
        if (eventHash != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final event = await EventRetrieveService.retrieveAndAddByHash(eventHash);
            if (context.mounted) {
              showCustomDialog(
                context,
                EventView(
                  eventHash: event.id,
                ),
              );
            }
          });
        }
      }
      UriService.saveUri("");
    }
  }

  void _changeMode(bool privateMode) {
    setState(() {
      _private = privateMode;
      Provider.of<CurrentEventsProvider>(context, listen: false).changeMode(_private);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: _private ? 'Agenda' : 'Eventi', actions: actions()),
      body: Consumer<CurrentEventsProvider>(builder: (context, eventsController, _) {
        return WeekView(
          eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
            return EventTile(
                confirmedView: _private,
                date: date,
                events: events.whereType<Event>().toList(),
                boundary: boundary,
                startDuration: startDuration,
                endDuration: endDuration);
          },
          controller: eventsController,
          showLiveTimeLineInAllDays: false,
          scrollOffset: 480.0,
          onEventTap: (events, date) {
            Event selectedEvent = events.whereType<Event>().toList().first;

            unawaited(EventRetrieveService.retrieveDetailsByHash(selectedEvent.id));

            showCustomDialog(
                context,
                EventView(
                  eventHash: selectedEvent.id,
                ));
          },
          onDateLongPress: (date) {
            showCustomDialog(
                context,
                EventView(
                  date: date,
                ));
          },
          startDay: WeekDays.monday,
          minuteSlotSize: MinuteSlotSize.minutes15,
          keepScrollOffset: true,
          onPageChange: (date, page) {
            // Update the range so listeners (like CurrentViewEventsProvider) are notified.
            rangeController.setRange(date, 7);
          },
        );
      }),
      floatingActionButton: AddEventButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<Widget> actions() {
    return [
      const SizedBox(width: 10),
      if (_private)
        Builder(
          builder: (context) {
            double screenWidth = MediaQuery.of(context).size.width;
            bool showText = screenWidth > 450;
            return showText
                ? Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        _changeMode(false);
                      },
                      icon: const Icon(Icons.event, size: 30, color: Colors.white),
                      label: showText
                          ? const Text(
                              'Eventi',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            )
                          : const SizedBox.shrink(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.event, size: 30),
                      onPressed: () {
                        _changeMode(false);
                      },
                    ),
                  );
          },
        ),
      if (!_private)
        Builder(
          builder: (context) {
            double screenWidth = MediaQuery.of(context).size.width;
            bool showText = screenWidth > 450;
            return showText
                ? Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        _changeMode(true);
                      },
                      icon: const Icon(Icons.event_available, size: 30, color: Colors.white),
                      label: showText
                          ? const Text(
                              'Agenda',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            )
                          : const SizedBox.shrink(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.event_available, size: 30),
                      onPressed: () {
                        _changeMode(true);
                      },
                    ),
                  );
          },
        ),
    ];
  }
}
