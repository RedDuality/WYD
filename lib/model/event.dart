import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/user_provider.dart';

// ignore: must_be_immutable
class Event extends CalendarEventData {
  final int id;
  final String? hash;
  final int? groupId;

  List<ProfileEvent> sharedWith = [];

  Event({
    this.id = 0,
    this.hash,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    DateTime? endDate,
    required super.title,
    super.description,
    super.color,
    super.descriptionStyle,
    TextStyle super.titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12.0,
      overflow: TextOverflow.clip,
    ),
    this.groupId,
    List<ProfileEvent>? sharedWith,
  })  : sharedWith = sharedWith ?? [],
        super(
          date: date.toLocal(),
          startTime: startTime.toLocal(),
          endTime: endTime.toLocal(),
          endDate: endDate?.toLocal(),
        );

  Event copy({
    String? title,
    String? description,
    CalendarEventData? event,
    Color? color,
    DateTime? startTime,
    DateTime? endTime,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    DateTime? endDate,
    DateTime? date,
    int? id,
    String? hash,
    int? groupId,
    List<ProfileEvent>? sharedWith,
  }) {
    return Event(
      id: id ?? this.id,
      hash: hash ?? this.hash,
      groupId: groupId ?? this.groupId,
      sharedWith: sharedWith ?? List<ProfileEvent>.from(this.sharedWith),
      date: date ?? this.date,
      startTime: startTime ?? this.startTime!,
      endTime: endTime ?? this.endTime!,
      endDate: endDate ?? this.endDate,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      titleStyle: titleStyle ?? this.titleStyle!,
    );
  }

  int totalShared() {
    return sharedWith.length;
  }

  int totalConfirmed() {
    return sharedWith.where((pe) => pe.confirmed == true).length;
  }

  String getConfirmTitle() {
    return totalShared() > 1
        ? "(${totalConfirmed()}/${totalShared()}) "
        : "";
  }

  bool confirmed() {
    int profileId = UserProvider().getCurrentProfileId();
    return sharedWith.firstWhere((pe) => pe.profileId == profileId).confirmed;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      _ => Event(
          id: json['id'] as int? ?? -1,
          hash: json['hash'] as String? ?? "",
          date: DateTime.parse(json['startTime'] as String),
          startTime: DateTime.parse(json['startTime'] as String),
          endTime: DateTime.parse(json['endTime'] as String),
          endDate: DateTime.parse(json['endTime'] as String),
          title: json['title'] as String? ?? "",
          description: json['description'] as String? ?? "",
          // Handle color parsing safely with a fallback
          color: json['color'] != null
              ? Color(int.parse(json['color'] as String))
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
      'startTime': startTime!.toUtc().toIso8601String(),
      'endTime': endTime!.toUtc().toIso8601String(),
      //'color': color.value,
      //if (groupId != null) 'groupId': groupId,
      'profileEvents': sharedWith.map((share) => share.toJson()).toList(),
    };
  }
}
