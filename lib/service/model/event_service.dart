import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/event_api.dart';
import 'package:wyd_front/API/user_api.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/event_provider.dart';

class EventService {
  Future<void> retrieveMultiple() async {
    UserAPI().listEvents().then((response) {
      if (response.statusCode == 200) {
        List<Event> events = List<Event>.from(
            json.decode(response.body).map((evento) => Event.fromJson(evento)));
        EventProvider().addAll(events);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

  Future<Event> retrieveUpdateByHash(String eventHash) async {
    var response = await EventAPI().retrieveFromHash(eventHash);

    if (response.statusCode == 200) {
      var event = Event.fromJson(jsonDecode(response.body));
      EventProvider().updateEvent(event);
      return event;
    }

    throw "Error while updating the event";
  }

  //automatically add the event
  Future<Event> retrieveNewByHash(String eventHash) async {
    var response = await EventAPI().sharedWithHash(eventHash);

    if (response.statusCode == 200) {
      var event = Event.fromJson(jsonDecode(response.body));
      EventProvider().add(event);
      return event;
    }

    throw "Error while retrieving event";
  }

  Future<Event> create(Event event) async {
    var response = await EventAPI().create(event);

    if (response.statusCode == 200) {
      Event event = Event.fromJson(jsonDecode(response.body));

      EventProvider().add(event);

      return event;
    } else {
      throw "Error while creating the event, please retry later";
    }
  }

  Future<Event> update(Event updatedEvent) async {
    var response = await EventAPI().update(updatedEvent);

    if (response.statusCode == 200) {
      Event event = Event.fromJson(jsonDecode(response.body));
      EventProvider().updateEvent(event);
      return event;
    } else {
      throw "Error while creating the event";
    }
  }

  Future<Event?> confirm(Event event) async {
    var response = await EventAPI().confirm(event.hash);
    if (response.statusCode == 200) {
      event.confirm();
      EventProvider().updateEvent(event);
      return event;
    } else {
      debugPrint(response.statusCode.toString());
      return null;
    }
  }

  Future<Event?> decline(Event event) async {
    var response = await EventAPI().decline(event.hash);

    if (response.statusCode == 200) {
      event.decline();
      EventProvider().updateEvent(event);
      return event;
    } else {
      debugPrint(response.statusCode.toString());
      return null;
    }
  }

  Future<void> shareToGroups(Event event, Set<int> groupsIds) async {
    EventAPI().shareToGroups(event.hash, groupsIds).then((response) {
      InformationService().showOverlaySnackBar("Evento condiviso con successo");
    }).catchError((error) {
      debugPrint(error.toString());
      InformationService().showOverlaySnackBar(error.toString());
    });
  }
}
