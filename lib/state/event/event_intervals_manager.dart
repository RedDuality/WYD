import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/state/event/event_intervals_storage.dart';

class EventIntervalsManager {
  final List<DateTimeRange> _intervals = [];

  final EventIntervalsStorage _storage = EventIntervalsStorage();

  late final StreamSubscription<void> _clearAllChannel;

  static final EventIntervalsManager _instance = EventIntervalsManager._internal();
  factory EventIntervalsManager() => _instance;
  EventIntervalsManager._internal() {
    if (kIsWeb) {
      _loadIntervals();

      _clearAllChannel = _storage.clearChannel.listen((_) {
        clearAll();
      });
    }
  }

  Future<void> _loadIntervals() async {
    final maps = await _storage.loadIntervals();
    _intervals.clear();
    if (maps.isNotEmpty) {
      _intervals.addAll(maps.map((map) => DateTimeInterval.fromDatabaseMap(map)));
    }
  }

  /// Adds a new interval to the cache, merging it with any existing overlaps and saving it to the database.
  Future<void> addInterval(DateTimeRange newInterval) async {
    DateTimeRange mergedInterval = newInterval;

    final overlappingIntervals = _intervals.where((interval) => interval.overlapsWith(newInterval)).toList();

    if (overlappingIntervals.isNotEmpty) {
      for (final interval in overlappingIntervals) {
        mergedInterval = mergedInterval.merge(interval);
        _intervals.remove(interval);
      }
    }

    _intervals.add(mergedInterval);
    // Sort the in-memory cache for efficient lookup.
    _intervals.sort((a, b) => a.start.compareTo(b.start));

    await _storage.addInterval(mergedInterval, overlappingIntervals);
  }

  /// Gets the first and last dates of the first missing interval.
  ///
  /// Returns a [DateTimeRange] representing the missing data, or `null`
  /// if the entire requested range is already in the cache.
  DateTimeRange? getMissingInterval(DateTimeRange requestedInterval) {
    // Check if the requested interval is fully covered by existing cache.
    final fullyCovered = _intervals.any((interval) =>
        !requestedInterval.start.isBefore(interval.start) && !requestedInterval.end.isAfter(interval.end));

    if (fullyCovered) return null;

    // Find the first uncovered start.
    final missingStart = _intervals.fold<DateTime>(
      requestedInterval.start,
      (start, interval) {
        if (start.isBefore(interval.start)) return start;
        if (start.isBefore(interval.end)) return interval.end;
        return start;
      },
    );

    if (!missingStart.isBefore(requestedInterval.end)) return null;

    // Find the uncovered end by scanning backwards.
    final missingEnd = _intervals.reversed.fold<DateTime>(
      requestedInterval.end,
      (end, interval) {
        if (end.isAfter(interval.end)) return end;
        if (end.isAfter(interval.start)) return interval.start;
        return end;
      },
    );

    return missingStart.isBefore(missingEnd) ? DateTimeRange(start: missingStart, end: missingEnd) : null;
  }

  void clearAll() {
    _intervals.clear();
  }

  void dispose() {
    _clearAllChannel.cancel();
  }
}
