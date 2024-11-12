import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile_event.dart';

// ignore: must_be_immutable
class TestEvent extends CalendarEventData {
  final int id;
  final String? hash;
  final int? groupId;

  List<ProfileEvent> sharedWith = [];

  TestEvent({
    this.id = -1,
    this.hash,
    required super.date,
    required super.startTime,
    required super.endTime,
    super.endDate,
    required super.title,
    super.description,
    super.color,
    super.descriptionStyle,
    this.groupId,
    List<ProfileEvent>? sharedWith,
  }) : sharedWith = sharedWith ?? [];

  factory TestEvent.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int? id,
        'hash': String? hash,
        'title': String? title,
        'description': String? description,
        'startTime': String startTime,
        'endTime': String endTime,
        'color': String? color,
        'groupId': int? groupId,
        'profileEvents': List<dynamic>? sharedWith,
      } =>
        TestEvent(
          id: id ?? -1,
          hash: hash ?? "",
          date: DateTime.parse(startTime),
          startTime: DateTime.parse(startTime),
          endTime: DateTime.parse(endTime),
          title: title ?? "",
          description: description ?? "",
          color:
              color != null ? Color(int.parse(color, radix: 16)) : Colors.green,
          groupId: groupId ?? -1,
          sharedWith: sharedWith != null ?
            sharedWith.map((pe) {return ProfileEvent.fromJson(pe as Map<String, dynamic>);}).toList() : <ProfileEvent>[],
        ),
      _ => throw const FormatException('Failed to decode Myevent')
    };
  }

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

  */
}