import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/user_provider.dart';

// ignore: must_be_immutable
class Event extends CalendarEventData {
  final String hash;
  final int? groupId;

  List<String> images = [];
  List<AssetEntity> cachedNewImages = [];
  List<ProfileEvent> sharedWith = [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Event) return false;
    return hash == other.hash;
  }

  @override
  int get hashCode => hash.hashCode;

  Event({
    this.hash = "",
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    DateTime? endDate,
    required super.title,
    super.description,
    super.color = Colors.green, // Default color
    super.descriptionStyle,
    TextStyle super.titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12.0,
      overflow: TextOverflow.clip,
    ),
    this.groupId,
    List<String>? images,
    List<AssetEntity>? newFiles,
    List<ProfileEvent>? sharedWith,
  })  : sharedWith = sharedWith ?? [],
        cachedNewImages = newFiles ?? [],
        images = images ?? [],
        super(
          date: date.toLocal(),
          startTime: startTime.toLocal(),
          endTime: endTime.toLocal(),
          endDate: endDate?.toLocal(),
        );

/*
  Event copy(
      {String? title,
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
      List<String>? images,
      List<ProfileEvent>? sharedWith}) {
    return Event(
      hash: hash ?? this.hash,
      groupId: groupId ?? this.groupId,
      images: images ?? List<String>.from(this.images),
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
  */

  int totalShared() {
    return sharedWith.length;
  }

  int totalConfirmed() {
    return sharedWith.where((pe) => pe.confirmed == true).length;
  }

  String getConfirmTitle() {
    return totalShared() > 1 ? "(${totalConfirmed()}/${totalShared()}) " : "";
  }

  ProfileEvent _getCurrentProfileEvent() {
    String profileHash = UserProvider().getCurrentProfileHash();
    return sharedWith.firstWhere((pe) => pe.profileHash == profileHash);
  }

  bool confirmed() {
    return _getCurrentProfileEvent().confirmed;
  }

  bool isOwner() {
    return _getCurrentProfileEvent().role == EventRole.owner;
  }

  void confirm(bool confirmed, {String? profHash}) {
    String profileHash = profHash ?? UserProvider().getCurrentProfileHash();
    sharedWith
        .firstWhere((confirm) => confirm.profileHash == profileHash)
        .confirmed = confirmed;
  }

  int countMatchingProfiles(Set<String> userProfileHashes) {
    int count = sharedWith
        .where((profileEvent) =>
            userProfileHashes.contains(profileEvent.profileHash))
        .length;
    return count;
  }
  
  void removeProfile(String hash) {
    sharedWith.removeWhere((profileEvent) => profileEvent.profileHash == hash);
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      _ => Event(
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
          images: json['blobHashes'] != null
              ? json['blobHashes'].cast<String>().toList()
              : <String>[],
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
      'hash': hash,
      'title': title,
      if (description != null) 'description': description,
      'startTime': startTime!.toUtc().toIso8601String(),
      'endTime': endTime!.toUtc().toIso8601String(),
      //'color': color.value,
      //if (groupId != null) 'groupId': groupId,
      'blobHashes': images,
      'profileEvents': sharedWith.map((share) => share.toJson()).toList(),
    };
  }
}
