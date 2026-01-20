class RetrieveMaskResponseDto {
  final String id;
  //final String profileId;
  final String? eventId;
  final String? title;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime? updatedAt;

  RetrieveMaskResponseDto({
    required this.id,
    //required this.profileId,
    this.eventId,
    this.title,
    required this.startTime,
    required this.endTime,
    this.updatedAt,
  });

  factory RetrieveMaskResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveMaskResponseDto(
        id: json['id'] as String,
        //profileId: json['profileId'] as String? ?? "",
        eventId: json['eventId'] as String?,
        title: json['title'] as String? ?? "",
        // Conversion to local is done in the mask constructor
        startTime: DateTime.parse(json['startTime'] as String).toUtc(),
        endTime: DateTime.parse(json['endTime'] as String).toUtc(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String).toUtc() : null);
  }
}
