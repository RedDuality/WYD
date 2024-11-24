import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/widget/dialog/event_dialog.dart';
import 'package:wyd_front/widget/event_tile.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    var privateEvents = context.watch<PrivateProvider>();

    return Scaffold(
      body: WeekView(
        eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
          return EventTile(date: date, events: events, boundary:boundary, startDuration: startDuration, endDuration: endDuration);
        } ,
        controller: privateEvents,
        showLiveTimeLineInAllDays: false,

        scrollOffset: 480.0,
        
        onEventTap: (events, date) => showEventDialog(context, events.whereType<Event>().toList().first, null, true),
        onDateLongPress: (date) => showEventDialog(context, null, date, true),
        minuteSlotSize: MinuteSlotSize.minutes15,
        keepScrollOffset: true,
      ),
    );
  }


}

