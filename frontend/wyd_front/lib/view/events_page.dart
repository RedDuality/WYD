import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/widget/add_event_button.dart';
import 'package:wyd_front/widget/dialog/event_dialog.dart';
import 'package:wyd_front/widget/event_tile.dart';

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
    var events = widget.private ? PrivateProvider() : SharedProvider();

    if (!widget.private) {
      if (!_dialogShown) {
        var eventHash = Uri.dataFromString(widget.uri).queryParameters['event'];
        if (eventHash != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final event = await EventService().retrieveFromHash(eventHash);

            if (event != null && context.mounted) {
              showEventDialog(context, event, null, event.confirmed());
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
              events: events,
              boundary: boundary,
              startDuration: startDuration,
              endDuration: endDuration);
        },
        controller: events,
        showLiveTimeLineInAllDays: false,
        scrollOffset: 480.0,
        onEventTap: (events, date) => showEventDialog(context,
            events.whereType<Event>().toList().first, null, widget.private),
        onDateLongPress: (date) =>
            showEventDialog(context, null, date, widget.private),
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
