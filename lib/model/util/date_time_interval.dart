
// Define an extension to add your custom methods to DateTimeRange
import 'package:flutter/material.dart';

extension DateTimeInterval on DateTimeRange {

  bool overlapsWith(DateTimeRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  /// Merges this range with another, assuming they overlap.
  DateTimeRange merge(DateTimeRange other) {
    final newStart = start.isBefore(other.start) ? start : other.start;
    final newEnd = end.isAfter(other.end) ? end : other.end;

    return DateTimeRange(start: newStart, end: newEnd); 
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'start_timestamp': start.millisecondsSinceEpoch,
      'end_timestamp': end.millisecondsSinceEpoch,
    };
  }

  static DateTimeRange fromDatabaseMap(Map<String, dynamic> map) {
    return DateTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(map['start_timestamp']),
      end: DateTime.fromMillisecondsSinceEpoch(map['end_timestamp']),
    );
  }
}