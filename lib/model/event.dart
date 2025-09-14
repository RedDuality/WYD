import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

// ignore: must_be_immutable
class Event extends CalendarEventData {
  final String eventHash;
  int totalConfirmed;
  int totalProfiles;
  bool hasCachedMedia = false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Event) return false;
    return eventHash == other.eventHash;
  }

  @override
  int get hashCode => eventHash.hashCode;

  Event({
    this.eventHash = "",
    required this.totalConfirmed,
    required this.totalProfiles,
    DateTime? date,
    required DateTime startTime,
    required DateTime endTime,
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
          endDate: endDate?.toLocal(),
        );

  factory Event.fromDto(RetrieveEventResponseDto dto) {
    return Event(
      eventHash: dto.hash,
      title: dto.title,
      startTime: dto.startTime,
      endTime: dto.endTime,
      totalProfiles: dto.totalProfiles,
      totalConfirmed: dto.totalConfirmed,
    );
  }

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

  String getConfirmTitle() {
    return totalProfiles > 1 ? "($totalConfirmed/$totalProfiles) " : "";
  }

  ProfileEvent _getCurrentProfileEvent() {
    String profileHash = UserProvider().getCurrentProfileHash();
    return ProfileEventsProvider().getSingle(eventHash, profileHash);
    //TODO return sharedWith.firstWhere((pe) => pe.profileHash == profileHash);
  }

  bool currentConfirmed() {
    return _getCurrentProfileEvent().confirmed;
  }

  bool isOwner() {
    return _getCurrentProfileEvent().role == EventRole.owner;
  }

  Set<String> profilesThatConfirmed() {
    var myprofiles = UserProvider().getProfileHashes().toSet();
    var eventProfiles = ProfileEventsProvider().get(eventHash);
    var result = eventProfiles
        .where((profileEvent) => profileEvent.confirmed && myprofiles.contains(profileEvent.profileHash))
        .map((profileEvent) => profileEvent.profileHash)
        .toSet();
    return result;
  }

  void confirm({String? profHash}) {
    String profileHash = profHash ?? UserProvider().getCurrentProfileHash();
    totalConfirmed += 1;
    ProfileEventsProvider().confirm(eventHash, profileHash);
  }

  void dismiss({String? profHash}) {
    String profileHash = profHash ?? UserProvider().getCurrentProfileHash();
    totalConfirmed -= 1;
    ProfileEventsProvider().dismiss(eventHash, profileHash);
  }

  // for delete
  void removeProfile(String profileHash) {
    ProfileEventsProvider().removeSingle(eventHash, profileHash);
  }

  //for delete
  int countMatchingProfiles(Set<String> userProfileHashes) {
    var myprofiles = UserProvider().getProfileHashes().toSet();
    var eventProfiles = ProfileEventsProvider().get(eventHash);
    var result = eventProfiles.where((profileEvent) => myprofiles.contains(profileEvent.profileHash)).length;
    return result;
  }
}
