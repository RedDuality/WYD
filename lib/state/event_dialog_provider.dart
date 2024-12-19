import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';

class EventDialogProvider extends ChangeNotifier {
  // Private static instance
  static final EventDialogProvider _instance = EventDialogProvider._internal();

  // Factory constructor returns the singleton instance
  factory EventDialogProvider() {
    return _instance;
  }

  // Private named constructor
  EventDialogProvider._internal();

  Event? event;

  





}
