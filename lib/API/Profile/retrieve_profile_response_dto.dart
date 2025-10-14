class RetrieveProfileResponseDto {
  final String id;
  final String tag;
  final String name;
  final DateTime updatedAt;

  RetrieveProfileResponseDto({
    required this.id,
    required this.tag,
    required this.name,
    required this.updatedAt,
  });

  factory RetrieveProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveProfileResponseDto(
      id: json['id'] as String,
      tag: json['tag'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
