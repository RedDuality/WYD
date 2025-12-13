import 'package:wyd_front/API/Mask/retrieve_mask_response_dto.dart';

/// Your pure data model for SQFlite storage.
class Mask {
  final String id;
  String? title;
  String? eventId;
  DateTime startTime; // Stored in UTC (as per your comment)
  DateTime endTime; // Stored in UTC
  DateTime? updatedAt;

  Mask({
    required this.id,
    this.title,
    this.eventId,
    // in Utc time
    required this.startTime,
    required this.endTime,
    this.updatedAt,
  });

  // Factory to create from a DTO (API response)
  factory Mask.fromDto(RetrieveMaskResponseDto dto) {
    return Mask(
      id: dto.id,
      title: dto.title,
      eventId: dto.eventId,
      // Ensure times are treated as UTC if that's your standard
      startTime: dto.startTime.toUtc(),
      endTime: dto.endTime.toUtc(),
      updatedAt: dto.updatedAt?.toUtc(),
    );
  }

  // Factory to create from a Database Map
  factory Mask.fromDbMap(Map<String, dynamic> map) {
    // Convert Unix timestamps (milliseconds since epoch) back to DateTime and force to UTC
    final startTime = DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int).toUtc();
    final endTime = DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int).toUtc();
    final updatedAtMillsecs = map['updatedAt'] as int?;
    final updatedAt = updatedAtMillsecs != null 
        ? DateTime.fromMillisecondsSinceEpoch(updatedAtMillsecs).toUtc() 
        : null;

    return Mask(
      id: map['id'] as String,
      title: map['title'] as String?,
      eventId: map['eventId'] as String?,
      startTime: startTime,
      endTime: endTime,
      updatedAt: updatedAt,
    );
  }

  /// Converts the Dart Event object to a Map for SQLite.
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'eventId': eventId,
      // Store as milliseconds since epoch for database efficiency
      'startTime': startTime.toUtc().millisecondsSinceEpoch,
      'endTime': endTime.toUtc().millisecondsSinceEpoch,
      'updatedAt': updatedAt?.toUtc().millisecondsSinceEpoch,
    };
  }

  // Helper for creating a copy (crucial for updating the CalendarMask)
  Mask copyWith({
    String? id,
    String? title,
    String? eventId,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? updatedAt,
  }) {
    return Mask(
      id: id ?? this.id,
      title: title ?? this.title,
      eventId: eventId ?? this.eventId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}