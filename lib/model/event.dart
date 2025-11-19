import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/service/event/profile_events_service.dart';
import 'package:wyd_front/state/user/user_provider.dart';

// ignore: must_be_immutable
class Event extends CalendarEventData {
  final String eventHash;
  DateTime updatedAt;
  int totalConfirmed;
  int totalProfiles;
  bool currentConfirmed = false;
  bool hasCachedMedia;

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
    // in Utc time
    required this.updatedAt,
    required this.totalConfirmed,
    required this.totalProfiles,
    required this.currentConfirmed,
    this.hasCachedMedia = false,
    DateTime? date,
    // in Utc time
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

  factory Event.fromDto(RetrieveEventResponseDto dto, bool currentConfirmed){
    return Event(
      eventHash: dto.hash,
      updatedAt: dto.updatedAt,
      title: dto.title,
      startTime: dto.startTime,
      endTime: dto.endTime,
      totalProfiles: dto.totalProfiles,
      totalConfirmed: dto.totalConfirmed,
      currentConfirmed: currentConfirmed,
    );
  }

  factory Event.fromDbMap(Map<String, dynamic> map) {
    // Convert Unix timestamps (milliseconds since epoch) back to DateTime
    final startTime = DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int).toUtc();
    final endTime = DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int).toUtc();
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int).toUtc();

    return Event(
      eventHash: map['eventHash'] as String,
      updatedAt: updatedAt,
      title: map['title'] as String,
      date: startTime,
      startTime: startTime,
      endTime: endTime,
      endDate: endTime,
      totalProfiles: map['totalProfiles'] as int,
      totalConfirmed: map['totalConfirmed'] as int,
      currentConfirmed: map['currentConfirmed'] == 1,
      hasCachedMedia: map['hasCachedMedia'] == 1,
    );
  }

  /// Converts the Dart Event object to a Map for SQLite.
  Map<String, dynamic> toDbMap() {
    return {
      'eventHash': eventHash,
      'title': title,
      'startTime': startTime!.toUtc().millisecondsSinceEpoch,
      'endTime': endTime!.toUtc().millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'totalConfirmed': totalConfirmed,
      'totalProfiles': totalProfiles,
      'hasCachedMedia': hasCachedMedia ? 1 : 0,
      'currentConfirmed': currentConfirmed ? 1: 0,
    };
  }

  String getConfirmTitle() {
    return totalProfiles > 1 ? "($totalConfirmed/$totalProfiles) " : "";
  }

  Future<ProfileEvent?> _getCurrentProfileEvent() async {
    String profileHash = UserProvider().getCurrentProfileHash();
    return await ProfileEventsStorageService().getSingle(eventHash, profileHash);
  }

  Future<bool> isOwner() async {
    var currentProfileEvent = await _getCurrentProfileEvent();
    return currentProfileEvent!.role == EventRole.owner;
  }

  Future<Set<String>> profilesThatConfirmed() async {
    var myprofiles = UserProvider().getProfileHashes().toSet();
    return await ProfileEventsStorageService().profilesThatConfirmed(eventHash, myprofiles);
  }

  //for delete
  Future<int> countMatchingProfiles(Set<String> userProfileHashes) async {
    var myprofiles = UserProvider().getProfileHashes().toSet();
    return await ProfileEventsStorageService().countMatchingProfiles(eventHash, myprofiles);
  }

  // for delete
  void removeProfile(String profileHash) {
    ProfileEventsStorageService().removeSingle(eventHash, profileHash);
  }
}
