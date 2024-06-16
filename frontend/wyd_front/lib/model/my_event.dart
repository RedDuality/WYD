import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wyd_front/model/confirm.dart';

class MyEvent extends Appointment {
  String? hash;
  List<Confirm> confirms = [];

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
    this.hash,
    this.confirms = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'subject': subject,
      'color': color.value.toRadixString(16),
      if(startTimeZone != null)'startTimeZone': startTimeZone,
      if(endTimeZone != null)'endTimeZone': endTimeZone,
      if(recurrenceRule != null)'recurrenceRule': recurrenceRule,
      //'recurrenceExceptionDates': recurrenceExceptionDates,
      if(notes != null)'notes': notes,
      if(location != null)'location': location,
      if(resourceIds != null)'resourceIds': resourceIds,
      if(recurrenceId != null)'recurrenceId': recurrenceId,
      if(id != null)'id': id,
      if(hash != null)'hash': hash,
      'userEvents': confirms.map((confirm) => confirm.toJson()).toList(), 
    };
  }

  factory MyEvent.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'startTime': String startTime,
        'endTime': String endTime,
        'isAllDay': bool? isAllDay,
        'subject': String? subject,
        'color': String? color,
        'startTimeZone': String? startTimeZone,
        'endTimeZone': String? endTimeZone,
        'recurrenceRule': String? recurrenceRule,
        //'recurrenceExceptionDates': recurrenceExceptionDates,
        'notes': String? notes,
        'location': String? location,
        'id': int? id,
        'hash': String? hash,
        'userEvents': List<dynamic>? confirms,
      } =>
        MyEvent(
            startTime: DateTime.parse(startTime), 
            endTime: DateTime.parse(endTime), 
            isAllDay: isAllDay ?? false,
            subject: subject ?? "",
            color: color != null ? Color(int.parse(color, radix: 16)) : Colors.green,
            startTimeZone: startTimeZone ?? "",
            endTimeZone: endTimeZone ?? "",
            recurrenceRule: recurrenceRule ?? "",
            notes: notes ?? "",
            location: location ?? "",
            id: id ?? -1,
            hash: hash ?? "",
            confirms: confirms != null ? confirms.map((confirm) => Confirm.fromJson( confirm as Map<String, dynamic>)).toList() : <Confirm>[],
        ),
      _ => throw const FormatException('Failed to decode Myevent')
    };
  }
}
