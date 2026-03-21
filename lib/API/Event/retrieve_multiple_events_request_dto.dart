class RetrieveMultipleEventsRequestDto {
  DateTime startTime;
  DateTime? endTime;

  RetrieveMultipleEventsRequestDto({
    required this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
    };
  }
}
