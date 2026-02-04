import 'package:wyd_front/model/events/event.dart';

class CreateEventRequestDto {
  String title;
  String? description;
  DateTime startTime;
  DateTime endTime;
  List<String>? invitedProfileIds;

  CreateEventRequestDto({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.invitedProfileIds,
  });

  factory CreateEventRequestDto.fromEvent(Event event, List<String> invitedProfileIds) {
    return CreateEventRequestDto(
      title: event.title,
      description: event.description,
      startTime: event.startTime!,
      endTime: event.endTime!,
      invitedProfileIds: invitedProfileIds, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'invitedProfileIds': invitedProfileIds, 
    };
  }
}
