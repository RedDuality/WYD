import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/state/event_provider.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/event/event_detail.dart';
import 'package:wyd_front/view/widget/event/event_tile.dart';
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
  bool _dialogShown = false;
  late bool _private;

  @override
  void initState() {
    super.initState();
    _private = widget.private;
    EventProvider(initialPrivate: _private);
  }

  checkAndShowLinkEvent(BuildContext context) {
    if (!widget.private) {
      if (!_dialogShown) {
        var eventHash = Uri.dataFromString(widget.uri).queryParameters['event'];
        if (eventHash != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final event = await EventService().retrieveNewByHash(eventHash);

            if (context.mounted) {
              showCustomDialog(
                  context,
                  EventDetail(
                      initialEvent: event,
                      date: null,
                      confirmed: event.confirmed()));
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
        controller: EventProvider(),
        showLiveTimeLineInAllDays: false,
        scrollOffset: 480.0,
        onEventTap: (events, date) => showCustomDialog(
          context,
          EventDetail(
              initialEvent: events.whereType<Event>().toList().first,
              date: null,
              confirmed: widget.private),
        ),
        onDateLongPress: (date) => showCustomDialog(
          context,
          EventDetail(
              initialEvent: null, date: date, confirmed: widget.private),
        ),
        minuteSlotSize: MinuteSlotSize.minutes15,
        keepScrollOffset: true,
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
            // Use MediaQuery to get the actual screen width
            double screenWidth = MediaQuery.of(context).size.width;
            bool showText = screenWidth > 450; // Adjust threshold as needed
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
                          EventProvider().changeMode(_private);
                        });
                      },
                      icon: const Icon(Icons.event,
                          size: 30, color: Colors.white),
                      label: showText
                          ? const Text(
                              'Eventi',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
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
                      color: Colors.blue, // Background color of the button
                      borderRadius:
                          BorderRadius.circular(8), // Optional: Rounded corners
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.event,
                          size: 30), // Icon inside the button
                      onPressed: () {
                        setState(() {
                          _private = false;
                          EventProvider().changeMode(_private);
                        });
                      },
                    ),
                  );
          },
        ),
      if (!_private)
        Builder(
          builder: (context) {
            // Use MediaQuery to get the actual screen width
            double screenWidth = MediaQuery.of(context).size.width;
            bool showText = screenWidth > 450; // Adjust threshold as needed
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
                          EventProvider().changeMode(_private);
                        });
                      },
                      icon: const Icon(Icons.event,
                          size: 30, color: Colors.white),
                      label: showText
                          ? const Text(
                              'Agenda',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
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
                      color: Colors.blue, // Background color of the button
                      borderRadius:
                          BorderRadius.circular(8), // Optional: Rounded corners
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.event,
                          size: 30), // Icon inside the button
                      onPressed: () {
                        setState(() {
                          _private = true;
                          EventProvider().changeMode(_private);
                        });
                      },
                    ),
                  );
          },
        ),
    ];
  }
}
