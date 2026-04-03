import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:rrule/rrule.dart';
import 'package:wyd_front/API/Event/retrieve_recurrent_event_response_dto.dart';
import 'package:wyd_front/model/events/event.dart';

// ignore: must_be_immutable
class RecurrentEvent extends CalendarEventData {
  final String id;
  DateTime updatedAt;

  final DateTime? recurrenceEnd;
  final RecurrenceRule recurrenceRule;

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
    final rruleString = dto.recurrenceRule.startsWith('RRULE:') ? dto.recurrenceRule : 'RRULE:${dto.recurrenceRule}';

    return RecurrentEvent(
        id: dto.id,
        updatedAt: dto.updatedAt,
        title: dto.title,
        startTime: dto.startTime,
        endTime: dto.endTime,
        recurrenceEnd: dto.recurrenceEnd,
        recurrenceRule: RecurrenceRule.fromString(rruleString));
  }

  factory RecurrentEvent.fromDbMap(Map<String, dynamic> map) {
    // Convert Unix timestamps (milliseconds since epoch) back to DateTime
    final startTime = DateTime.fromMillisecondsSinceEpoch(map['sTime'] as int).toUtc();
    final endTime = DateTime.fromMillisecondsSinceEpoch(map['eTime'] as int).toUtc();
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int).toUtc();
    final recurrenceEnd = map['rEnd'] != null ? DateTime.fromMillisecondsSinceEpoch(map['rEnd'] as int) : null;

    final rawRrule = map['rRule'] as String;
    final rruleString = rawRrule.startsWith('RRULE:') ? rawRrule : 'RRULE:$rawRrule';

    return RecurrentEvent(
      id: map['id'] as String,
      updatedAt: updatedAt,
      title: map['title'] as String,
      date: startTime,
      startTime: startTime,
      endTime: endTime,
      endDate: endTime,
      recurrenceEnd: recurrenceEnd,
      recurrenceRule: RecurrenceRule.fromString(rruleString),
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
      'rRule': recurrenceRule.toString(),
    };
  }

  bool hasEventFinished() {
    return DateTime.now().isAfter(endTime!);
  }

  Event _getInstanceFromMaster(DateTime startTime, Duration duration) {
    final utcDate = startTime.toUtc();
    final instanceId = _formatRecurrenceId(utcDate);

    return Event(
      id: "${id}_$instanceId",
      masterEventId: id,
      recurrencyInstanceId: instanceId,
      updatedAt: updatedAt,
      title: title,
      description: description,
      startTime: utcDate,
      endTime: utcDate.add(duration),
      totalConfirmed: 1,
      totalProfiles: 1,
      detachedInstance: false,
      recurrenceRule: recurrenceRule,
      color: color,
    );
  }

  List<Event> generateOccurrences(DateTimeRange interval) {
    final masterStart = startTime!.toUtc().copyWith(millisecond: 0, microsecond: 0);
    final intervalStart = interval.start.toUtc().copyWith(millisecond: 0, microsecond: 0);

    // If the interval starts before the event's first occurrence,
    // start searching from the event's first occurrence instead.
    final effectiveAfter = intervalStart.isBefore(masterStart) ? masterStart : intervalStart;

    final occurrences = recurrenceRule.getInstances(
      start: masterStart,
      after: effectiveAfter,
      includeAfter: true,
      before: interval.end.toUtc().copyWith(millisecond: 0, microsecond: 0),
    );

    return expandOccurrences(occurrences);
  }

  List<Event> expandOccurrences(Iterable<DateTime> occurrences) {
    final List<Event> newInstances = [];
    final dur = endTime!.difference(startTime!);

    for (final sTime in occurrences) {
      newInstances.add(_getInstanceFromMaster(sTime, dur));
    }
    return newInstances;
  }

  Event generateCurrentOccurence(DateTime startsAt) {
    final utcStart = startsAt.toUtc().copyWith(millisecond: 0, microsecond: 0);

    if (!_isValidOccurrence(utcStart)) {
      throw ArgumentError("The provided startTime is not a valid recurrence instance.");
    }

    final duration = endTime!.difference(startTime!);

    return _getInstanceFromMaster(startsAt, duration);
  }

  bool _isValidOccurrence(DateTime startsAt) {
    final masterStart = startTime!.toUtc().copyWith(millisecond: 0, microsecond: 0);


    final searchAfter = startsAt.subtract(const Duration(seconds: 1));
    // Ensure we don't look "after" a date that is before the "start"
    final effectiveAfter = searchAfter.isBefore(masterStart) ? masterStart : searchAfter;

    // We check occurrences in a 1-second window around the target
    final occurrences = recurrenceRule.getInstances(
      start: masterStart,
      after: effectiveAfter,
      includeAfter: true,
      before: startsAt.add(const Duration(seconds: 1)),
    );

    return occurrences.any((d) => d.toUtc().isAtSameMomentAs(startsAt));
  }

  /// Helper to format the instance ID consistently
  String _formatRecurrenceId(DateTime date) {
    return "${date.toIso8601String().replaceAll(RegExp(r'[:\-]'), '').split('.').first}Z";
  }
}
