
import 'package:timezone/timezone.dart' as tz;

class CreateRecurrentEventRequestDto {
  String title;
  String? description;
  DateTime startTime;
  DateTime endTime;
  bool isAllDay;
  String recurrenceRule;
  String timeZoneId;
  final DateTime cacheIntervalStart;
  final DateTime cacheIntervalEnd;

  CreateRecurrentEventRequestDto({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    required this.recurrenceRule,
    String? timeZoneId,
    required this.cacheIntervalStart,
    required this.cacheIntervalEnd,
  }): timeZoneId = timeZoneId ?? tz.local.name;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'isAllDay': isAllDay,
      'timeZone': timeZoneId,
      'recurrenceRule': recurrenceRule,
      'cacheIntervalStart': cacheIntervalStart.toUtc().toIso8601String(),
      'cacheIntervalEnd': cacheIntervalEnd.toUtc().toIso8601String(),
    };
  }
}
