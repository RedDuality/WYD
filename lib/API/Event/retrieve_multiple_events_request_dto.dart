class RetrieveMultipleEventsRequestDto {
  Set<String> profileHashes;
  DateTime startTime;
  DateTime? endTime;

  RetrieveMultipleEventsRequestDto({
    required this.profileHashes,
    required this.startTime,
    this.endTime,
  });


  Map<String, dynamic> toJson() {
    return {
      'profileHashes': profileHashes,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
    };
  }
}
