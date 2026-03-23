import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';

// ignore: must_be_immutable
class Event extends CalendarEventData {
  final String id;
  DateTime updatedAt;
  int totalConfirmed;
  int totalProfiles;

  String masterEventId;
  String? recurrencyInstanceId;
  bool detachedInstance;

  String? importedAccountId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Event) return false;
    return id == other.id && updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, updatedAt);

  bool get isGeneratedInstance => masterEventId.isNotEmpty && !detachedInstance;
  
  Event({
    this.id = "",
    // in Utc time
    required this.updatedAt,
    required this.totalConfirmed,
    required this.totalProfiles,
    DateTime? date,
    // in Utc time
    required DateTime startTime,
    required DateTime endTime,

    required this.masterEventId,
    this.recurrencyInstanceId,
    this.detachedInstance = false,

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
      id: dto.id,
      updatedAt: dto.updatedAt,
      title: dto.title,
      startTime: dto.startTime,
      endTime: dto.endTime,
      totalProfiles: dto.totalProfiles,
      totalConfirmed: dto.totalConfirmed,

      masterEventId: dto.masterEventId,
      recurrencyInstanceId: dto.recurrencyInstanceId,
      detachedInstance: dto.detachedInstance,
    );
  }

  factory Event.fromDbMap(Map<String, dynamic> map) {
    // Convert Unix timestamps (milliseconds since epoch) back to DateTime
    final startTime = DateTime.fromMillisecondsSinceEpoch(map['sTime'] as int).toUtc();
    final endTime = DateTime.fromMillisecondsSinceEpoch(map['eTime'] as int).toUtc();
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int).toUtc();

    return Event(
      id: map['id'] as String,
      updatedAt: updatedAt,
      title: map['title'] as String,
      date: startTime,
      startTime: startTime,
      endTime: endTime,
      endDate: endTime,
      totalProfiles: map['totalProfiles'] as int,
      totalConfirmed: map['totalConfirmed'] as int,
      masterEventId: map['masterEventId'] as String,
      recurrencyInstanceId: map['recurrencyInstanceId'] as String?,
      detachedInstance: map['detachedInstance'] as bool,
    );
  }

  /// Converts the Dart Event object to a Map for SQLite.
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'sTime': startTime!.toUtc().millisecondsSinceEpoch,
      'eTime': endTime!.toUtc().millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'totalConfirmed': totalConfirmed,
      'totalProfiles': totalProfiles,
      'masterEventId': masterEventId,
      'recurrencyInstanceId': recurrencyInstanceId,
      'detachedInstance': detachedInstance,
    };
  }

  String getConfirmTitle() {
    return totalProfiles > 1 ? "($totalConfirmed/$totalProfiles) " : "";
  }

  // for automatic image retrieval
  bool hasEventFinished() {
    return DateTime.now().isAfter(endTime!);
  }
}
