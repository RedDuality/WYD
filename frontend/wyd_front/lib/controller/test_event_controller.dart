
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/my_event.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/state/events_provider.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class TestEventController {



  Future<void> confirm(BuildContext context, CalendarEventData event) async {
    var private = context.read<PrivateProvider>();
    var public = context.read<SharedProvider>();
    
    private.add(event);
    public.remove(event);

  }

  Future<void> decline(BuildContext context, MyEvent event) async {
    var private = context.read<EventsProvider>().privateEvents;
    var public = context.read<EventsProvider>().sharedEvents;
    int userId = context.read<UserProvider>().user!.id;

    EventService().decline(event).then((response) {
      if (response.statusCode == 200) {
        event.confirms
                .firstWhere((confirm) => confirm.userId == userId)
                .confirmed ==
            false;
        public.addAppointement(event);
        private.removeAppointment(event);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }
}
