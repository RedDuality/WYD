
class DateTimeInterval {
  final DateTime start;
  final DateTime end;

  DateTimeInterval(this.start, this.end);

  // A helper method to check if this interval overlaps with another.
  bool overlapsWith(DateTimeInterval other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  DateTimeInterval merge(DateTimeInterval other) {
    final newStart = start.isBefore(other.start) ? start : other.start;
    final newEnd = end.isAfter(other.end) ? end : other.end;
    return DateTimeInterval(newStart, newEnd);
  }

/*
  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  factory DateTimeInterval.fromJson(Map<String, dynamic> json) {
    return DateTimeInterval(
      DateTime.parse(json['start']),
      DateTime.parse(json['end']),
    );
  }
*/
  
  // Convert to a format suitable for database insertion.
  Map<String, dynamic> toDatabaseMap() {
    return {
      'start_timestamp': start.millisecondsSinceEpoch,
      'end_timestamp': end.millisecondsSinceEpoch,
    };
  }

  // Create from a database map.
  factory DateTimeInterval.fromDatabaseMap(Map<String, dynamic> map) {
    return DateTimeInterval(
      DateTime.fromMillisecondsSinceEpoch(map['start_timestamp']),
      DateTime.fromMillisecondsSinceEpoch(map['end_timestamp']),
    );
  }
}