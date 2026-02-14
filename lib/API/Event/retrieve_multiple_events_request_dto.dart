class RetrieveMultipleEventsRequestDto {
  Set<String> profileIds;
  DateTime startTime;
  DateTime? endTime;

  RetrieveMultipleEventsRequestDto({
    required this.profileIds,
    required this.startTime,
    this.endTime,
  });


  Map<String, dynamic> toJson() {
    return {
      'profileIds': profileIds.toList(),
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
    };
  }
}
