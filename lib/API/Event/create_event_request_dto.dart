import 'package:wyd_front/model/events/event.dart';

class CreateEventRequestDto {
  String title;
  String? description;
  DateTime startTime;
  DateTime endTime;

  CreateEventRequestDto({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
  });

  factory CreateEventRequestDto.fromEvent(Event event) {
    return CreateEventRequestDto(
        title: event.title, description: event.description, startTime: event.startTime!, endTime: event.endTime!);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
    };
  }
}
