import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wyd_front/service/api.dart';
import 'package:wyd_front/model/confirm.dart';
import 'package:wyd_front/model/my_event.dart';
import 'package:wyd_front/state/shared_events.dart';

class Events{
  Future<void> initEvents() async {


    String response = await Api().listEvents();

    Iterable list = json.decode(response);
    List<MyEvent> eventi = List<MyEvent>.from(list.map( (evento) => MyEvent.fromJson(evento)));

    List<MyEvent> private = eventi.where((event) => event.confirms.contains(Confirm(1, true))).toList();
    List<MyEvent> public = eventi.where((event) => event.confirms.contains(Confirm(1, false))).toList();


    //TODO aggiornare stato: aggiungere private a privateEvents e public a publicevents(da creare)
    
    //debugPrint('$eventi');
  }
}