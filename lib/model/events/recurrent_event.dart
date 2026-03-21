import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_recurrent_event_response_dto.dart';

// ignore: must_be_immutable
class RecurrentEvent extends CalendarEventData {
  final String id;
  DateTime updatedAt;

  final DateTime? recurrenceEnd;
  final String recurrenceRule;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RecurrentEvent) return false;
    return id == other.id && updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, updatedAt);

  RecurrentEvent({
    this.id = "",
    // in Utc time
    required this.updatedAt,
    DateTime? date,
    // in Utc time
    required DateTime startTime,
    required DateTime endTime,
    required this.recurrenceEnd,
    required this.recurrenceRule,
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

  factory RecurrentEvent.fromDto(RetrieveRecurrentEventResponseDto dto) {
    return RecurrentEvent(
      id: dto.id,
      updatedAt: dto.updatedAt,
      title: dto.title,
      startTime: dto.startTime,
      endTime: dto.endTime,
      recurrenceEnd: dto.recurrenceEnd,
      recurrenceRule: dto.recurrenceRule
    );
  }

  factory RecurrentEvent.fromDbMap(Map<String, dynamic> map) {
    // Convert Unix timestamps (milliseconds since epoch) back to DateTime
    final startTime = DateTime.fromMillisecondsSinceEpoch(map['sTime'] as int).toUtc();
    final endTime = DateTime.fromMillisecondsSinceEpoch(map['eTime'] as int).toUtc();
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int).toUtc();
    final recurrenceEnd = map['rEnd'] != null ?  DateTime.fromMillisecondsSinceEpoch(map['rEnd'] as int) : null;

    return RecurrentEvent(
      id: map['id'] as String,
      updatedAt: updatedAt,
      title: map['title'] as String,
      date: startTime,
      startTime: startTime,
      endTime: endTime,
      endDate: endTime,

      recurrenceEnd: recurrenceEnd,
      recurrenceRule: map['rRule'] as String,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'sTime': startTime!.toUtc().millisecondsSinceEpoch,
      'eTime': endTime!.toUtc().millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'rEnd': recurrenceEnd?.millisecondsSinceEpoch,
      'rRule': recurrenceRule,
    };
  }

  bool hasEventFinished() {
    return DateTime.now().isAfter(endTime!);
  }
}
