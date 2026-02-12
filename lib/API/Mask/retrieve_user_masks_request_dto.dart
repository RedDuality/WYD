class RetrieveUserMasksRequestDto {
  DateTime startTime;
  DateTime? endTime;

  RetrieveUserMasksRequestDto({
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
