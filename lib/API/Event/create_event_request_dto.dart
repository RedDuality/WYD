import 'package:wyd_front/API/Community/share_event_request_dto.dart';

class CreateEventRequestDto {
  String title;
  String? description;
  DateTime startTime;
  DateTime endTime;
  ShareEventRequestDto? shareDto;

  CreateEventRequestDto({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.shareDto,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'shareDto': shareDto,
    };
  }
}
