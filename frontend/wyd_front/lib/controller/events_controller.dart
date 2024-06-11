import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/my_event.dart';
import 'package:wyd_front/service/user_service.dart';
import 'package:wyd_front/state/my_app_state.dart';

class EventController {
  Future<void> retrieveEvents(BuildContext context) async {
    UserService().listEvents().then((response) {
      if (response.statusCode == 200) {
        List<MyEvent> eventi = List<MyEvent>.from(json
            .decode(response.body)
            .map((evento) => MyEvent.fromJson(evento)));
        setEvents(context, eventi);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  void setEvents(BuildContext context, List<MyEvent> eventi) {
    int userId = context.read<MyAppState>().user.id;

    List<MyEvent> private = eventi
        .where((event) => event.confirms
            .where((c) => c.id == userId && c.confirmed == true)
            .isNotEmpty)
        .toList();
    List<MyEvent> public = eventi
        .where((event) => event.confirms
            .where((c) => c.id == userId && c.confirmed == false)
            .isNotEmpty)
        .toList();

    context.read<MyAppState>().privateEvents.setAppointements(private);
    context.read<MyAppState>().sharedEvents.setAppointements(public);
  }
}
