class UpdateMaskRequestDto {
  String maskId; 
  String? title;
  DateTime? startTime;
  DateTime? endTime;

  UpdateMaskRequestDto({
    required this.maskId,
    this.title,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'maskId': maskId,
      'title': title,
      'startTime': startTime?.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
    };
  }
}
