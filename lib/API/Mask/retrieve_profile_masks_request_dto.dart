class RetrieveProfileMasksRequestDto {
  String profileId;
  DateTime startTime;
  DateTime? endTime;

  RetrieveProfileMasksRequestDto({
    required this.profileId,
    required this.startTime,
    this.endTime,
  });


  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
    };
  }
}
