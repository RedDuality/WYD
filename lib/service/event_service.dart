import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/API/event_api.dart';
import 'package:wyd_front/API/user_api.dart';
import 'package:wyd_front/service/information_service.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class EventService {
  Future<void> retrieveEvents() async {
    UserAPI().listEvents().then((response) {
      if (response.statusCode == 200) {
        List<Event> eventi = List<Event>.from(
            json.decode(response.body).map((evento) => Event.fromJson(evento)));
        addEvents(eventi);
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

  void addEvents(List<Event> events) {
    int mainProfileId = UserProvider().getMainProfileId();

    List<Event> sharedEvents = events
        .where((ev) =>
            ev.sharedWith
                .firstWhere((s) => s.profileId == mainProfileId)
                .confirmed ==
            false)
        .toList();
    List<Event> privateEvents = events
        .where((ev) =>
            ev.sharedWith
                .firstWhere((s) => s.profileId == mainProfileId)
                .confirmed ==
            true)
        .toList();

    PrivateProvider().addEvents(privateEvents);
    SharedProvider().addEvents(sharedEvents);
  }

  Future<Event> create(Event event) async {
    var response = await EventAPI().create(event);

    if (response.statusCode == 200) {
      Event event = Event.fromJson(jsonDecode(response.body));

      event.confirmed()
          ? PrivateProvider().addEvent(event)
          : SharedProvider().addEvent(event);
      return event;
    } else {
      throw "Error while creating the event, please retry later";
    }
  }

  Future<Event> update(Event originalEvent, Event updatedEvent) async {
    var response = await EventAPI().update(updatedEvent);

    if (response.statusCode == 200) {
      updatedEvent.confirmed()
          ? PrivateProvider().update(originalEvent, updatedEvent)
          : SharedProvider().update(originalEvent, updatedEvent);
      return updatedEvent;
    } else {
      throw "Error while creating the event";
    }
  }

  Future<void> shareToGroups(Event event, Set<int> groupsIds) async {

    EventAPI().shareToGroups(event.id, groupsIds).then((response) {
      InformationService().showOverlaySnackBar("Evento condiviso con successo");
    }).catchError((error) {
      debugPrint(error.toString());
      InformationService().showOverlaySnackBar(error.toString());
    });

  }

  Future<Event?> confirm(Event event) async {
    var private = PrivateProvider();
    var public = SharedProvider();
    int profileId = UserProvider().getMainProfileId();

    var response = await EventAPI().confirm(event);
    if (response.statusCode == 200) {
      event.sharedWith
          .firstWhere((confirm) => confirm.profileId == profileId)
          .confirmed = true;
      private.addEvent(event);
      public.remove(event);
      return event;
    } else {
      debugPrint(response.statusCode.toString());
      return null;
    }
  }

  Future<Event?> decline(Event event) async {
    var private = PrivateProvider();
    var public = SharedProvider();
    int profileId = UserProvider().getMainProfileId();

    var response = await EventAPI().decline(event);

    if (response.statusCode == 200) {
      event.sharedWith
          .firstWhere((confirm) => confirm.profileId == profileId)
          .confirmed = false;
      private.remove(event);
      public.addEvent(event);
      return event;
    } else {
      debugPrint(response.statusCode.toString());
      return null;
    }
  }
}
