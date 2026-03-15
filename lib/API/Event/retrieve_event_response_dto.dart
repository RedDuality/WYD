import 'package:wyd_front/model/events/event_details.dart';
import 'package:wyd_front/model/profiles/profile_event.dart';

class RetrieveEventResponseDto {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime updatedAt;
  final int totalProfiles;
  final int totalConfirmed;
  
  final String? masterEventId;
  final String? recurrencyInstanceId;
  final bool detachedInstance;

  final EventDetails? details;

  Set<ProfileEvent>? sharedWith = {};

  RetrieveEventResponseDto({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.updatedAt,
    required this.totalProfiles,
    required this.totalConfirmed,
    this.masterEventId,
    this.recurrencyInstanceId,
    this.detachedInstance = false,
    this.details,
    this.sharedWith,
  });

  factory RetrieveEventResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveEventResponseDto(
      id: json['id'] as String,
      title: json['title'] as String? ?? "",
      startTime:
          DateTime.parse(json['startTime'] as String).toUtc(), // Conversion to local is done in the event constructor
      endTime: DateTime.parse(json['endTime'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
      totalConfirmed: json['totalConfirmed'] as int? ?? 1,
      totalProfiles: json['totalProfiles'] as int? ?? 1,
      masterEventId: json['masterEventId'] as String?,
      recurrencyInstanceId: json['recurrencyInstanceId'] as String?,
      detachedInstance: json['detachedInstance'] as bool? ?? false,
      details:
          json['eventDetails'] != null ? EventDetails.fromJson(json['eventDetails'] as Map<String, dynamic>) : null,
      sharedWith: (json['profileEvents'] as List<dynamic>?)
              ?.map((pe) => ProfileEvent.fromJson(json['id'] as String, pe as Map<String, dynamic>))
              .toSet() ??
          <ProfileEvent>{},
    );
  }
}
