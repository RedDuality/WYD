import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile_event.dart';

// ignore: must_be_immutable
class Event extends CalendarEventData {
  final int id;
  final String? hash;
  final int? groupId;

  List<ProfileEvent> sharedWith = [];

  Event({
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

  ProfileEvent? getProfileEvent(int profileId) {
    return sharedWith.firstWhere((pe) => pe.profileId == profileId);
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      _ => Event(
          id: json['id'] as int? ?? -1,
          hash: json['hash'] as String? ?? "",
          date: DateTime.parse(json['startTime'] as String),
          startTime: DateTime.parse(json['startTime'] as String),
          endTime: DateTime.parse(json['endTime'] as String),
          title: json['title'] as String? ?? "",
          description: json['description'] as String? ?? "",
          // Handle color parsing safely with a fallback
          color: json['color'] != null
              ? Color(int.parse(json['color'] as String, radix: 16))
              : Colors.green,
          groupId: json['groupId'] as int? ?? -1,
          sharedWith: (json['profileEvents'] as List<dynamic>?)
                  ?.map(
                      (pe) => ProfileEvent.fromJson(pe as Map<String, dynamic>))
                  .toList() ??
              <ProfileEvent>[],
        )
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (hash != null) 'hash': hash,
      'title': title,
      //if (description != null) 'description': description,
      'startTime': startTime!.toIso8601String(),
      'endTime': endTime!.toIso8601String(),
      //'color': color.value.toRadixString(16),
      //if (groupId != null) 'groupId': groupId,
      'profileEvents': sharedWith.map((share) => share.toJson()).toList(),
    };
  }
}
