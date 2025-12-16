import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';

abstract class IntervalStorage {
  Stream<void> get clearChannel;
  Future<List<Map<String, dynamic>>> loadIntervals();
  Future<void> addInterval(DateTimeRange merged, List<DateTimeRange> overlapping);
}

class IntervalsCache<T extends IntervalStorage> {
  final List<DateTimeRange> _intervals = [];
  final T _storage;

  late final StreamSubscription<void> _clearAllChannel;

  IntervalsCache(this._storage) {
    if (kIsWeb) {
      _loadIntervals();
      _clearAllChannel = _storage.clearChannel.listen((_) => clearAll());
    }
  }

  Future<void> _loadIntervals() async {
    final maps = await _storage.loadIntervals();
    _intervals
      ..clear()
      ..addAll(maps.map((map) => DateTimeInterval.fromDatabaseMap(map)));
  }

  Future<void> addInterval(DateTimeRange newInterval) async {
    DateTimeRange mergedInterval = newInterval;
    final overlapping = _intervals.where((i) => i.overlapsWith(newInterval)).toList();

    for (final interval in overlapping) {
      mergedInterval = mergedInterval.merge(interval);
      _intervals.remove(interval);
    }

    _intervals.add(mergedInterval);
    _intervals.sort((a, b) => a.start.compareTo(b.start));

    unawaited(_storage.addInterval(mergedInterval, overlapping));
  }

  DateTimeRange? getMissingInterval(DateTimeRange requested) {
    final fullyCovered = _intervals.any((i) => !requested.start.isBefore(i.start) && !requested.end.isAfter(i.end));
    if (fullyCovered) return null;

    final missingStart = _intervals.fold<DateTime>(
      requested.start,
      (start, i) {
        if (start.isBefore(i.start)) return start;
        if (start.isBefore(i.end)) return i.end;
        return start;
      },
    );

    if (!missingStart.isBefore(requested.end)) return null;

    final missingEnd = _intervals.reversed.fold<DateTime>(
      requested.end,
      (end, i) {
        if (end.isAfter(i.end)) return end;
        if (end.isAfter(i.start)) return i.start;
        return end;
      },
    );

    return missingStart.isBefore(missingEnd) ? DateTimeRange(start: missingStart, end: missingEnd) : null;
  }

  void clearAll() => _intervals.clear();

  void dispose() => _clearAllChannel.cancel();
}
