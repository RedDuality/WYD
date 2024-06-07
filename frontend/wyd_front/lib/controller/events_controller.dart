import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/confirm.dart';
import 'package:wyd_front/model/my_event.dart';
import 'package:wyd_front/service/user_service.dart';
import 'package:wyd_front/state/my_app_state.dart';

class EventController {
  Future<void> initEvents(BuildContext context) async {
    UserService().listEvents().then((response) {
      if (response.statusCode == 200) {
        debugPrint(response.body);
        _updateEvents(context, json.decode(response.body));
      }
    }).catchError((error) {});
  }

  void _updateEvents(BuildContext context, Iterable events) {
    List<MyEvent> eventi =
        List<MyEvent>.from(events.map((evento) => MyEvent.fromJson(evento)));

    debugPrint(eventi.length.toString());

    List<MyEvent> private = eventi
        .where((event) => event.confirms.where((c) => c.id == 2 && c.confirmed == true).length == 1)
        .toList();
    List<MyEvent> public = eventi
        .where((event) => event.confirms.contains(Confirm(2, false)))
        .toList();

    debugPrint(private.length.toString());
    debugPrint(public.length.toString());

    context.read<MyAppState>().privateEvents.setAppointements(private);
    context.read<MyAppState>().sharedEvents.setAppointements(public);

    //TODO aggiornare stato: aggiungere private a privateEvents e public a publicevents(da creare)

    //debugPrint('$eventi');
  }
}
