class RetrieveViewMaskResponseDto {
  final String id;
  final String? eventId;
  final String? title;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime updatedAt;

  RetrieveViewMaskResponseDto({
    required this.id,
    this.eventId,
    this.title,
    required this.startTime,
    required this.endTime,
    required this.updatedAt,
  });

  factory RetrieveViewMaskResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveViewMaskResponseDto(
        id: json['id'] as String,
        eventId: json['eventId'] as String?,
        title: json['title'] as String? ?? "",
        // Conversion to local is done in the mask constructor
        startTime: DateTime.parse(json['startTime'] as String).toUtc(),
        endTime: DateTime.parse(json['endTime'] as String).toUtc(),
        updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc());
  }
}
