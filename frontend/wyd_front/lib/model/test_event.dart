import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/confirm.dart';

class TestEvent extends CalendarEventData {
  int id;
  String? hash;
  List<Confirm> confirms = [];

  TestEvent({
    required super.startTime,
    required super.endTime,
    required super.title,
    required super.date,
    super.color,
    super.description,
    super.descriptionStyle,
    super.endDate,
    this.id = 0,
    this.hash,
    this.confirms = const [],
  });


/*
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

  factory TestEvent.fromJson(Map<String, dynamic> json) {
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
        TestEvent(
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
  }*/
}
