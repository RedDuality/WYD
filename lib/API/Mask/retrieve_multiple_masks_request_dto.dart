class RetrieveMultipleMasksRequestDto {
  Set<String> profileHashes;
  DateTime startTime;
  DateTime? endTime;

  RetrieveMultipleMasksRequestDto({
    required this.profileHashes,
    required this.startTime,
    this.endTime,
  });


  Map<String, dynamic> toJson() {
    return {
      'profileHashes': profileHashes.toList(),
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
    };
  }
}
