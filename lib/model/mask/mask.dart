import 'package:wyd_front/API/Mask/retrieve_mask_response_dto.dart';

class Mask {
  final String id;
  String? title;
  String? eventId;
  DateTime startTime; // Stored in UTC
  DateTime endTime; // Stored in UTC
  DateTime updatedAt;

  Mask({
    required this.id,
    this.title,
    this.eventId,
    // in Utc time
    required this.startTime,
    required this.endTime,
    required this.updatedAt,
  });

  factory Mask.fromDto(RetrieveMaskResponseDto dto) {
    return Mask(
      id: dto.id,
      title: dto.title,
      eventId: dto.eventId,
      // Ensure times are treated as UTC if that's your standard
      startTime: dto.startTime.toUtc(),
      endTime: dto.endTime.toUtc(),
      updatedAt: dto.updatedAt.toUtc(),
    );
  }

  // Factory to create from a Database Map
  factory Mask.fromDbMap(Map<String, dynamic> map) {
    // Convert Unix timestamps (milliseconds since epoch) back to DateTime and force to UTC
    final startTime = DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int).toUtc();
    final endTime = DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int).toUtc();
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int).toUtc();

    return Mask(
      id: map['id'] as String,
      title: map['title'] as String?,
      eventId: map['eventId'] as String?,
      startTime: startTime,
      endTime: endTime,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'eventId': eventId,
      'startTime': startTime.toUtc().millisecondsSinceEpoch,
      'endTime': endTime.toUtc().millisecondsSinceEpoch,
      'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
    };
  }

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
