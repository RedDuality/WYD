import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/state/event/range_controller.dart';
import 'package:wyd_front/state/event/events_cache.dart';
import 'package:wyd_front/state/event_view_orchestrator.dart';
import 'package:wyd_front/state/profileEvent/profile_events_cache.dart';
import 'package:wyd_front/state/user/view_settings_cache.dart';
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
  late RangeController _rangeController;
  late EventViewOrchestrator _viewOrchestrator;

  @override
  void initState() {
    super.initState();

    _rangeController = RangeController(DateTime.now(), 7);

    final appEventsCache = context.read<EventsCache>();
    final profileEventsCache = context.read<ProfileEventsCache>();
    final vsCache = context.read<ViewSettingsCache>();

    _viewOrchestrator = EventViewOrchestrator(
      eventsCache: appEventsCache,
      peCache: profileEventsCache,
      vsCache: vsCache,
      rangeController: _rangeController,
      confirmedView: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewOrchestrator.initialize();
      unawaited(_checkAndShowLinkEvent(context));
    });
  }

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowLinkEvent(BuildContext context) async {
    final uri = await UriService.getUri();
    if (uri.isNotEmpty) {
      final destination = uri.split('?').first.replaceAll('/', '');
      if (destination == 'share') {
        var eventId = Uri.dataFromString(uri).queryParameters['event'];
        unawaited(UriService.saveUri(""));
        if (eventId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final event = await EventRetrieveService.retrieveAndAddByHash(eventId);
            if (context.mounted) {
              showCustomDialog(
                context,
                EventView(
                  eventId: event.id,
                ),
              );
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewOrchestrator,
      child: Scaffold(
        appBar:
            Header(title: _viewOrchestrator.confirmedView ? 'Agenda' : 'Eventi', actions: actions()),
        body: Consumer<EventsCache>(builder: (context, eventsController, _) {
          return WeekView(
            eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
              return EventTile(
                  confirmedView: _viewOrchestrator.confirmedView,
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
                    eventId: selectedEvent.id,
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
              _viewOrchestrator.controller.setRange(date, 7);
            },
          );
        }),
        floatingActionButton: AddEventButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  List<Widget> actions() {
    return [
      const SizedBox(width: 10),
      if (_viewOrchestrator.confirmedView)
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
                        _viewOrchestrator.changeMode(false);
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
                        _viewOrchestrator.changeMode(false);
                      },
                    ),
                  );
          },
        ),
      if (!_viewOrchestrator.confirmedView)
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
                        _viewOrchestrator.changeMode(true);
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
                        _viewOrchestrator.changeMode(true);
                      },
                    ),
                  );
          },
        ),
    ];
  }
}
