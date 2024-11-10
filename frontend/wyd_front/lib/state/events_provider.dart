import 'package:flutter/material.dart';
import 'package:wyd_front/model/events_data_source.dart';




class EventsProvider extends ChangeNotifier {

  EventsDataSource privateEvents = EventsDataSource();
  EventsDataSource sharedEvents = EventsDataSource();




}
