import 'package:flutter/material.dart'; 

/// It must extend Listenable so that the CurrentEventsNotifier can subscribe to it.
abstract class EventRangeController extends Listenable {

  DateTimeRange get focusedRange;

}