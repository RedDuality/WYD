import 'package:wyd_front/API/Community/retrieve_group_response_dto.dart';
import 'package:wyd_front/model/enum/community_type.dart';

class RetrieveCommunityResponseDto {
  String id;
  String? name;
  CommunityType type;
  DateTime updatedAt;
  String? otherProfileId;
  List<RetrieveGroupResponseDto> groups;

  RetrieveCommunityResponseDto({
    required this.id,
    this.name,
    required this.type,
    required this.updatedAt,
    this.otherProfileId,
    required this.groups,
  });

  factory RetrieveCommunityResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveCommunityResponseDto(
      id: json['id'],
      name: json['name'] as String?,
      type: CommunityType.values[json['type'] ?? 0],
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
      otherProfileId: json['otherProfileId'] as String?,
      groups: (json['groups'] as List<dynamic>)
          .map((g) => RetrieveGroupResponseDto.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }
}
