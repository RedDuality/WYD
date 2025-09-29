import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/state/event/calendar_view_event_controller.dart';
import 'package:wyd_front/state/event/calendar_view_week_adapter.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/events/event_tile.dart';
import 'package:wyd_front/view/events/eventEditor/event_view.dart';
import 'package:wyd_front/view/widget/header.dart';
import 'package:wyd_front/view/widget/util/add_event_button.dart';

class EventsPage extends StatefulWidget {
  final String uri;
  final bool private;
  const EventsPage({super.key, required this.private, this.uri = ""});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final weekViewAdapter = CalendarViewWeekAdapter();

  bool _dialogShown = false;
  late bool _private;

  @override
  void initState() {
    super.initState();
    _private = widget.private;

    CalendarViewEventController(initialPrivate: _private);

    _retrieveCurrentViewEvent();
  }

  void _retrieveCurrentViewEvent() {
    final range = weekViewAdapter.focusedRange;

    // The focusedRange is already a DateTimeRange(start, end)
    EventRetrieveService.retrieveMultiple(range.start, range.end);
  }

  void checkAndShowLinkEvent(BuildContext context) {
    if (!widget.private) {
      if (!_dialogShown) {
        var eventHash = Uri.dataFromString(widget.uri).queryParameters['event'];
        if (eventHash != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final event = await EventRetrieveService.retrieveAndAddByHash(eventHash);

            EventViewService.initialize(event, null, event.currentConfirmed());
            if (context.mounted) {
              showCustomDialog(
                  context,
                  EventView(
                    eventHash: event.eventHash,
                  ));
            }
          });
          _dialogShown = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    checkAndShowLinkEvent(context);

    return Scaffold(
      appBar: Header(title: _private ? 'Agenda' : 'Eventi', actions: actions()),
      body: WeekView(
        eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
          return EventTile(
              date: date,
              events: events.whereType<Event>().toList(),
              boundary: boundary,
              startDuration: startDuration,
              endDuration: endDuration);
        },
        controller: CalendarViewEventController(),
        showLiveTimeLineInAllDays: false,
        scrollOffset: 480.0,
        onEventTap: (events, date) {
          Event selectedEvent = events.whereType<Event>().toList().first;

          EventViewService.initialize(selectedEvent, null, widget.private);

          showCustomDialog(
              context,
              EventView(
                eventHash: selectedEvent.eventHash,
              ));
        },
        onDateLongPress: (date) {
          EventViewService.initialize(null, date, widget.private);

          showCustomDialog(context, EventView());
        },
        startDay: WeekDays.monday,
        minuteSlotSize: MinuteSlotSize.minutes15,
        keepScrollOffset: true,
        onPageChange: (date, page) {
          // 1. Update the adapter so listeners (like WeekEventsNotifier) are notified.
          weekViewAdapter.updateFocusedDate(date);

          // 2. ❌ REMOVE THE REDUNDANT CALL:
          // var endDate = date.add(const Duration(days: 7));
          // EventRetrieveService.retrieveMultiple(date, endDate);
          // The WeekEventsNotifier should now handle this automatically.
        },
        /*
        onPageChange: (date, page) {
          var endDate = date.add(const Duration(days: 7));
          EventRetrieveService.retrieveMultiple(date, endDate);
        },*/
      ),
      floatingActionButton: AddEventButton(
        confirmed: widget.private,
      ),
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
                        setState(() {
                          _private = false;
                          CalendarViewEventController().changeMode(_private);
                        });
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
                        setState(() {
                          _private = false;
                          CalendarViewEventController().changeMode(_private);
                        });
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
                        setState(() {
                          _private = true;
                          CalendarViewEventController().changeMode(_private);
                        });
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
                        setState(() {
                          _private = true;
                          CalendarViewEventController().changeMode(_private);
                        });
                      },
                    ),
                  );
          },
        ),
    ];
  }
}
