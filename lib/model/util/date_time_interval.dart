// Define an extension to add your custom methods to DateTimeRange
import 'package:flutter/material.dart';

extension DateTimeInterval on DateTimeRange {
  bool overlapsWith(DateTimeRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  DateTimeRange? getOverlap(DateTimeRange other) {
    final overlapStart = start.isAfter(other.start) ? start : other.start;
    final overlapEnd = end.isBefore(other.end) ? end : other.end;
    return !overlapStart.isBefore(overlapEnd) ? null : DateTimeRange(start: overlapStart, end: overlapEnd);
  }

  /// Merges this range with another, assuming they overlap.
  DateTimeRange merge(DateTimeRange other) {
    final newStart = start.isBefore(other.start) ? start : other.start;
    final newEnd = end.isAfter(other.end) ? end : other.end;

    return DateTimeRange(start: newStart, end: newEnd);
  }

  List<DateTimeRange> getRemovedIntervals(DateTimeRange newRange) {
    final removed = <DateTimeRange>[];

    if (newRange.start.isAfter(start)) {
      removed.add(DateTimeRange(start: start, end: newRange.start));
    }
    if (newRange.end.isBefore(end)) {
      removed.add(DateTimeRange(start: newRange.end, end: end));
    }

    return removed;
  }

  List<DateTimeRange> getAddedIntervals(DateTimeRange newRange) {
    final added = <DateTimeRange>[];

    if (!overlapsWith(newRange)) {
      added.add(newRange);
      return added;
    }

    if (newRange.start.isBefore(start)) {
      added.add(DateTimeRange(start: newRange.start, end: start));
    }
    if (newRange.end.isAfter(end)) {
      added.add(DateTimeRange(start: end, end: newRange.end));
    }

    return added;
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'start_timestamp': start.toUtc().millisecondsSinceEpoch,
      'end_timestamp': end.toUtc().millisecondsSinceEpoch,
    };
  }

  static DateTimeRange fromDatabaseMap(Map<String, dynamic> map) {
    return DateTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(map['start_timestamp']).toUtc(),
      end: DateTime.fromMillisecondsSinceEpoch(map['end_timestamp']).toUtc(),
    );
  }
}
