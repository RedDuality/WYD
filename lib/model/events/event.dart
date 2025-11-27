import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';

// ignore: must_be_immutable
class Event extends CalendarEventData {
  final String id;
  DateTime updatedAt;
  int totalConfirmed;
  int totalProfiles;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Event) return false;
    return id == other.id && updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, updatedAt);

  Event({
    this.id = "",
    // in Utc time
    required this.updatedAt,
    required this.totalConfirmed,
    required this.totalProfiles,
    DateTime? date,
    // in Utc time
    required DateTime startTime,
    required DateTime endTime,
    DateTime? endDate,
    required super.title,
    super.description,
    super.color = Colors.green, // Default color
    super.descriptionStyle,
    super.titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12.0,
      overflow: TextOverflow.clip,
    ),
  }) : super(
          date: date ?? startTime.toLocal(),
          startTime: startTime.toLocal(),
          endTime: endTime.toLocal(),
          endDate: endDate ?? endTime.toLocal(),
        );

  factory Event.fromDto(RetrieveEventResponseDto dto) {
    return Event(
      id: dto.id,
      updatedAt: dto.updatedAt,
      title: dto.title,
      startTime: dto.startTime,
      endTime: dto.endTime,
      totalProfiles: dto.totalProfiles,
      totalConfirmed: dto.totalConfirmed,
    );
  }

  factory Event.fromDbMap(Map<String, dynamic> map) {
    // Convert Unix timestamps (milliseconds since epoch) back to DateTime
    final startTime = DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int).toUtc();
    final endTime = DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int).toUtc();
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int).toUtc();

    return Event(
      id: map['id'] as String,
      updatedAt: updatedAt,
      title: map['title'] as String,
      date: startTime,
      startTime: startTime,
      endTime: endTime,
      endDate: endTime,
      totalProfiles: map['totalProfiles'] as int,
      totalConfirmed: map['totalConfirmed'] as int,
    );
  }

  /// Converts the Dart Event object to a Map for SQLite.
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime!.toUtc().millisecondsSinceEpoch,
      'endTime': endTime!.toUtc().millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'totalConfirmed': totalConfirmed,
      'totalProfiles': totalProfiles,
    };
  }

  String getConfirmTitle() {
    return totalProfiles > 1 ? "($totalConfirmed/$totalProfiles) " : "";
  }

  bool hasEventFinished() {
    return DateTime.now().isAfter(endTime!);
  }
}
