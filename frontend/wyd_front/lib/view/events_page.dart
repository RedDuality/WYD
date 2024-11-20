import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/widget/dialog/create_event_dialog.dart';
import 'package:wyd_front/widget/dialog/event_dialog.dart';
import 'package:wyd_front/widget/dialog/shared_dialog.dart';

class EventsPage extends StatelessWidget {
  final String uri;
  const EventsPage({super.key, this.uri = ""});

  @override
  Widget build(BuildContext context) {
    var privateEvents = context.watch<SharedProvider>();

    var eventHash = Uri.dataFromString(uri).queryParameters['event'];

    if (eventHash != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showSharedDialog(context, eventHash!);
      });
    }
    eventHash = null;

    return Scaffold(
      body: WeekView(
        controller: privateEvents,
        showLiveTimeLineInAllDays: false,
        heightPerMinute: 0.75,
        keepScrollOffset: true,
        emulateVerticalOffsetBy: 2,
        onEventTap: (events, date) => showEventDialog(
            context, events.whereType<Event>().toList().first, false),
        onDateTap: (date) => showCreateEventDialog(context, date, false),
      ),
    );
  }
}
