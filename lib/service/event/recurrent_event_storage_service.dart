import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/state/event/recurrent_event_storage.dart';

class RecurrentEventStorageService {
  /// Returns all generated [Event] occurrences whose *start* falls inside [requestedInterval].
  static Future<List<Event>> generateEventsInTimeRange(DateTimeRange requestedInterval) async {
    final masters = await RecurrentEventStorage().getMastersInRange(requestedInterval);

    return masters.expand((m) => m.generateOccurrences(requestedInterval)).toList();
  }

  /// Returns all generated [Event] occurrences whose *end* falls inside [requestedInterval].
  ///
  /// For each master the occurrence-start search window is shifted back by the
  /// master's own duration, so that only occurrences whose computed endTime
  /// lands inside the requested interval are produced — without over-fetching.
  static Future<List<Event>> generateEventsEndingInTimeRange(DateTimeRange requestedInterval) async {
    final masters = await RecurrentEventStorage().getMastersInRange(requestedInterval);

    return masters
        .expand((m) {
          final duration = m.endTime!.difference(m.startTime!);

          // Shift the search window so that occurrence.start + duration ∈ [rangeStart, rangeEnd],
          // i.e. occurrence.start ∈ [rangeStart - duration, rangeEnd - duration].
          final searchRange = DateTimeRange(
            start: requestedInterval.start.subtract(duration),
            end: requestedInterval.end.subtract(duration),
          );

          return m.generateOccurrences(searchRange);
        })
        .where((e) {
          final end = e.endTime!.toUtc();
          return !end.isBefore(requestedInterval.start.toUtc()) &&
              !end.isAfter(requestedInterval.end.toUtc());
        })
        .toList()
      ..sort((a, b) => a.endTime!.compareTo(b.endTime!));
  }
}