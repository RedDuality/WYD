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
        //'description': String? description,
        'startTime': String startTime,
        'endTime': String endTime,
        //'color': String? color,
        //'groupId': int? groupId,
        'profileEvents': List<dynamic>? sharedWith,
      } =>
        TestEvent(
          id: id ?? -1,
          hash: hash ?? "",
          date: DateTime.parse(startTime),
          startTime: DateTime.parse(startTime),
          endTime: DateTime.parse(endTime),
          title: title ?? "",
          //description: description ?? "",
          //color: color != null ? Color(int.parse(color, radix: 16)) : Colors.green,
          //groupId: groupId ?? -1,
          sharedWith: sharedWith?.map((pe) {
                return ProfileEvent.fromJson(pe as Map<String, dynamic>);
              }).toList() ??
              <ProfileEvent>[],
        ),
      _ => throw FormatException('Failed to decode TestEvent.'),
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (hash != null) 'hash': hash,
      'title': title,
      if (description != null) 'description': description,
      'startTime': startTime!.toIso8601String(),
      'endTime': endTime!.toIso8601String(),
      'color': color.value.toRadixString(16),
      if (groupId != null) 'groupId': groupId,
      'profileEvents': sharedWith.map((share) => share.toJson()).toList(),
    };
  }
}
