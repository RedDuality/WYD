import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/widget/dialog/create_event_dialog.dart';
import 'package:wyd_front/widget/dialog/event_dialog.dart';
import 'package:wyd_front/widget/dialog/shared_dialog.dart';
import 'package:wyd_front/widget/event_tile.dart';

class EventsPage extends StatefulWidget {
  final String uri;
  const EventsPage({super.key, this.uri = ""});


  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool _dialogShown = false;
  
 // Track whether the dialog has been shown

  @override
  Widget build(BuildContext context) {
    var sharedEvents = context.watch<SharedProvider>();

    if (!_dialogShown) {
      var eventHash = Uri.dataFromString(widget.uri).queryParameters['event'];
      if (eventHash != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSharedDialog(context, eventHash); // Show dialog
        });
        _dialogShown = true; // Mark dialog as shown
      }
    }
        return Scaffold(
      body: WeekView(
        eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
          return EventTile(date: date, events: events, boundary:boundary, startDuration: startDuration, endDuration: endDuration);
        } ,
        controller: sharedEvents,
        showLiveTimeLineInAllDays: false,

        scrollOffset: 480.0,
        
        onEventTap: (events, date) => showEventDialog(context, events.whereType<Event>().toList().first, true),
        onDateLongPress: (date) => showCreateEventDialog(context, date, true),
        minuteSlotSize: MinuteSlotSize.minutes15,
        keepScrollOffset: true,
      ),
    );

  }
}
