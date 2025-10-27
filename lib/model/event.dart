import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

// ignore: must_be_immutable
class Event extends CalendarEventData{
  final String eventHash;
  DateTime updatedAt;
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
    required this.updatedAt,
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
          endDate: endDate ?? endTime.toLocal(),
        );

  factory Event.fromDto(RetrieveEventResponseDto dto) {
    return Event(
      eventHash: dto.hash,
      updatedAt: dto.updatedAt,
      title: dto.title,
      startTime: dto.startTime,
      endTime: dto.endTime,
      totalProfiles: dto.totalProfiles,
      totalConfirmed: dto.totalConfirmed,
    );
  }

  factory Event.fromDbMap(Map<String, dynamic> map) {
    // Convert Unix timestamps (milliseconds since epoch) back to DateTime
    final startTime = DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int).toLocal();
    final endTime = DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int).toLocal();
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int).toLocal();

    return Event(
      eventHash: map['eventHash'] as String,
      updatedAt: updatedAt,
      title: map['title'] as String,
      startTime: startTime,
      endTime: endTime,
      totalProfiles: map['totalProfiles'] as int,
      totalConfirmed: map['totalConfirmed'] as int,
      // Pass the DateTime properties to the CalendarEventData super constructor
      date: startTime.toLocal(),
      endDate: endTime.toLocal(),
    );
  }

  String getConfirmTitle() {
    return totalProfiles > 1 ? "($totalConfirmed/$totalProfiles) " : "";
  }

  ProfileEvent _getCurrentProfileEvent() {
    String profileHash = UserProvider().getCurrentProfileHash();
    return ProfileEventsProvider().getSingle(eventHash, profileHash)!;
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

  //for delete
  int countMatchingProfiles(Set<String> userProfileHashes) {
    var myprofiles = UserProvider().getProfileHashes().toSet();
    var eventProfiles = ProfileEventsProvider().get(eventHash);
    var result = eventProfiles.where((profileEvent) => myprofiles.contains(profileEvent.profileHash)).length;
    return result;
  }

  // for delete
  void removeProfile(String profileHash) {
    ProfileEventsProvider().removeSingle(eventHash, profileHash);
  }

}
