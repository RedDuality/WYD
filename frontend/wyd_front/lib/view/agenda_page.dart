import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/widget/dialog/event_dialog.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    var privateEvents = context.watch<PrivateProvider>();

    return Scaffold(
      body: WeekView(
        controller: privateEvents,
        showLiveTimeLineInAllDays: false,
        heightPerMinute: 0.75,
        keepScrollOffset: true,
        emulateVerticalOffsetBy: 2,
        onEventTap: (events, date) => showEventDialog(context, events.whereType<Event>().toList().first, true),
      ),
    );
  }
}

