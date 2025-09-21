class UpdateEventRequestDto {
  final String eventHash;
  final String? title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;

  UpdateEventRequestDto({
    required this.eventHash,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventHash,
      'title': title,
      'description': description,
      'startTime': startTime?.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
    };
  }
}
