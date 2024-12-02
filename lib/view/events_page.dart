import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/widget/util/add_event_button.dart';
import 'package:wyd_front/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/widget/event/event_detail.dart';
import 'package:wyd_front/widget/event/event_tile.dart';

class EventsPage extends StatefulWidget {
  final String uri;
  final bool private;
  const EventsPage({super.key, this.private = true, this.uri = ""});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    var eventsProvider = widget.private ? PrivateProvider() : SharedProvider();

    if (!widget.private) {
      if (!_dialogShown) {
        var eventHash = Uri.dataFromString(widget.uri).queryParameters['event'];
        if (eventHash != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final event = await EventService().retrieveFromHash(eventHash);

            if (event != null && context.mounted) {
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

    return Scaffold(
      body: WeekView(
        eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
          return EventTile(
              date: date,
              events: events.whereType<Event>().toList(),
              boundary: boundary,
              startDuration: startDuration,
              endDuration: endDuration);
        },
        controller: eventsProvider,
        showLiveTimeLineInAllDays: false,
        scrollOffset: 480.0,
        onEventTap: (events, date) => showCustomDialog(
            context,
            EventDetail(
                initialEvent: events.whereType<Event>().toList().first,
                date: null,
                confirmed: widget.private)),
        onDateLongPress: (date) => showCustomDialog(
            context,
            EventDetail(
                initialEvent: null, date: date, confirmed: widget.private)),
        minuteSlotSize: MinuteSlotSize.minutes15,
        keepScrollOffset: true,
      ),
      floatingActionButton: AddEventButton(
        confirmed: widget.private,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
