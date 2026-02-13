class CreateMaskRequestDto {
  String? title;
  DateTime startTime;
  DateTime endTime;

  CreateMaskRequestDto({
    this.title,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
    };
  }
}
