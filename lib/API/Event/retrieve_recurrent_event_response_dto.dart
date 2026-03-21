import 'package:wyd_front/model/events/event_details.dart';
import 'package:wyd_front/model/profiles/profile_event.dart';

class RetrieveRecurrentEventResponseDto {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime updatedAt;

  final DateTime? recurrenceEnd;
  final String recurrenceRule;

  final EventDetails? details;

  Set<ProfileEvent>? sharedWith = {};

  RetrieveRecurrentEventResponseDto({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.updatedAt,
    this.recurrenceEnd,
    required this.recurrenceRule,
    this.details,
    this.sharedWith,
  });

  factory RetrieveRecurrentEventResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveRecurrentEventResponseDto(
      id: json['id'] as String,
      title: json['title'] as String? ?? "",
      startTime:
          DateTime.parse(json['startTime'] as String).toUtc(), // Conversion to local is done in the event constructor
      endTime: DateTime.parse(json['endTime'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
      recurrenceEnd: json['recurrenceEnd'] != null ? DateTime.parse(json['recurrenceEnd'] as String).toUtc() : null,
      recurrenceRule: json['recurrenceRule'],
      details:
          json['eventDetails'] != null ? EventDetails.fromJson(json['eventDetails'] as Map<String, dynamic>) : null,
      sharedWith: (json['profileEvents'] as List<dynamic>?)
              ?.map((pe) => ProfileEvent.fromJson(json['id'] as String, pe as Map<String, dynamic>))
              .toSet() ??
          <ProfileEvent>{},
    );
  }
}
