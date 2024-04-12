import 'package:syncfusion_flutter_calendar/calendar.dart';

class MyEvent extends Appointment {
  String? link;

  MyEvent({
    required super.startTime,
    required super.endTime,
    super.isAllDay,
    super.subject,
    super.color,
    super.startTimeZone,
    super.endTimeZone,
    super.recurrenceRule,
    super.recurrenceExceptionDates,
    super.notes,
    super.location,
    super.resourceIds,
    super.recurrenceId,
    super.id,
    this.link = 'linkciao',
  });


  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'subject': subject,
      'color': color.value.toRadixString(16),
      'startTimeZone': startTimeZone,
      'endTimeZone': endTimeZone,
      'recurrenceRule': recurrenceRule,
      //'recurrenceExceptionDates': recurrenceExceptionDates,
      'notes': notes,
      'location': location,
      'resourceIds': resourceIds,
      'recurrenceId': recurrenceId,
      'id': id,
      'link': link,
    };
  }


}
