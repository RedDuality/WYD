import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/my_event.dart';
import 'package:wyd_front/model/test_event.dart';
import 'package:wyd_front/API/event_api.dart';
import 'package:wyd_front/API/user_api.dart';
import 'package:wyd_front/state/events_provider.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class MyEventService {
  late BuildContext context;
  
  MyEventService({required this.context});

  Future<void> retrieveEvents( ) async {

    UserAPI().listEvents().then((response) {
      if (response.statusCode == 200 && context.mounted) {
        List<TestEvent> eventi = List<TestEvent>.from(json
            .decode(response.body)
            .map((evento) => MyEvent.fromJson(evento)));
        addEvents(context, eventi);
      }

    }).catchError((error) {
      debugPrint(error.toString());
    });

  }

  Future<MyEvent?> retrieveFromHash(
      BuildContext context, String eventHash) async {
    MyEvent? event;
    await EventAPI().retrieveFromHash(eventHash).then((response) {
      if (response.statusCode == 200) {
        event = MyEvent.fromJson(jsonDecode(response.body));
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });

    return event;
  }

  void addEvents(BuildContext context, List<TestEvent> events) {
    int mainProfileId = context.read<UserProvider>().getMainProfileId();

    List<TestEvent> sharedEvents = events
        .where((ev) =>
            ev.sharedWith
                .firstWhere((s) => s.profileId == mainProfileId)
                .confirmed ==
            true)
        .toList();
    List<TestEvent> privateEvents = events
        .where((ev) =>
            ev.sharedWith
                .firstWhere((s) => s.profileId == mainProfileId)
                .confirmed ==
            true)
        .toList();

    context.read<PrivateProvider>().addEvents(privateEvents);
    context.read<SharedProvider>().addEvents(sharedEvents);
  }

  Future<void> createEvent(TestEvent event) async {
    EventAPI().create(event).then((response) {
      if (response.statusCode == 200 && context.mounted) {
        TestEvent event = TestEvent.fromJson(jsonDecode(response.body));
        context.read<PrivateProvider>().addEvent(event);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<void> share(BuildContext context, Appointment event,
      List<Community> communities) async {
    Set<int> userIds = {};
    for (var c in communities) {
      if (c.users != null && c.users!.isNotEmpty) {
        for (var u in c.users!) {
          userIds.add(u.id);
        }
      }
    }

    EventAPI()
        .share(event.id as int, userIds)
        .then((response) {})
        .catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<bool> confirmFromHash(
      BuildContext context, MyEvent event, bool confirm) async {
    bool res = false;
    await EventAPI().confirmFromHash(event.hash!, confirm).then((response) {
      if (response.statusCode == 200) {
        res = true;
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });

    return res;
  }

  Future<void> confirm(TestEvent event) async {
    var private = context.read<EventsProvider>().privateEvents;
    var public = context.read<EventsProvider>().sharedEvents;
    int userId = context.read<UserProvider>().user!.id;

/*
    EventAPI().confirm(event).then((response) {
      if (response.statusCode == 200) {
        event.confirms
                .firstWhere((confirm) => confirm.userId == userId)
                .confirmed ==
            true;
        private.addAppointement(event);
        public.removeAppointment(event);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });*/
  }

  Future<void> decline(BuildContext context, MyEvent event) async {
    var private = context.read<EventsProvider>().privateEvents;
    var public = context.read<EventsProvider>().sharedEvents;
    int userId = context.read<UserProvider>().user!.id;

    EventAPI().decline(event).then((response) {
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
