import 'package:flutter/material.dart'; 

/// It must extend Listenable so that the CurrentEventsNotifier can subscribe to it.
abstract class AbstractEventRangeController extends Listenable {

  DateTimeRange get focusedRange;

  /// Signals the calendar to move to the previous period.
  void prev();

  /// Signals the calendar to move to the next period.
  void next();

  /// Signals the calendar to reset to the current day/week/month.
  void reset();

  /// Clean up resources.
  void dispose();
}