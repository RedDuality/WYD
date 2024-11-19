import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/event_api.dart';
import 'package:wyd_front/API/user_api.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class EventService {
  late BuildContext context;
  
  EventService({required this.context});

  Future<void> retrieveEvents( ) async {

    UserAPI().listEvents().then((response) {
      if (response.statusCode == 200 && context.mounted) {
        List<Event> eventi = List<Event>.from(json
            .decode(response.body)
            .map((evento) => Event.fromJson(evento)));
        addEvents(context, eventi);
      }

    }).catchError((error) {
      debugPrint(error.toString());
    });

  }

  Future<Event?> retrieveFromHash(String eventHash) async {
    Event? event;
    await EventAPI().retrieveFromHash(eventHash).then((response) {
      if (response.statusCode == 200) {
        event = Event.fromJson(jsonDecode(response.body));
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });

    return event;
  }

  void addEvents(BuildContext context, List<Event> events) {
    int mainProfileId = context.read<UserProvider>().getMainProfileId();

    List<Event> sharedEvents = events
        .where((ev) =>
            ev.sharedWith
                .firstWhere((s) => s.profileId == mainProfileId)
                .confirmed == false)
        .toList();
    List<Event> privateEvents = events
        .where((ev) =>
            ev.sharedWith
                .firstWhere((s) => s.profileId == mainProfileId)
                .confirmed == true)
        .toList();

    context.read<PrivateProvider>().addEvents(privateEvents);
    context.read<SharedProvider>().addEvents(sharedEvents);
  }

  Future<void> createEvent(Event event) async {

    EventAPI().create(event).then((response) {
      if (response.statusCode == 200 && context.mounted) {
        Event event = Event.fromJson(jsonDecode(response.body));
        context.read<PrivateProvider>().addEvent(event);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<void> share(Event event,
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
        .share(event.id, userIds)
        .then((response) {})
        .catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<bool> confirmFromHash(
      BuildContext context, Event event, bool confirm) async {
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

  Future<void> confirm(Event event) async {
    var private = context.read<PrivateProvider>();
    var public = context.read<SharedProvider>();
    int profileId = context.read<UserProvider>().getMainProfileId();

    EventAPI().confirm(event).then((response) {
      if (response.statusCode == 200) {
        event.sharedWith
                .firstWhere((confirm) => confirm.profileId == profileId)
                .confirmed == true;
        private.addEvent(event);
        public.remove(event);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<void> decline(Event event) async {
    var private = context.read<PrivateProvider>();
    var public = context.read<SharedProvider>();
    int profileId = context.read<UserProvider>().getMainProfileId();

    EventAPI().decline(event).then((response) {
      if (response.statusCode == 200) {
        event.sharedWith
                .firstWhere((confirm) => confirm.profileId == profileId)
                .confirmed == true;
        private.remove(event);
        public.add(event);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

}
