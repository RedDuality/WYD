import 'package:wyd_front/model/enum/group_role.dart';

class RetrieveGroupResponseDto {
  String id;
  String? name;
  bool isMainGroup;
  GroupRole role;

  RetrieveGroupResponseDto({
    required this.id,
    this.name,
    required this.isMainGroup,
    required this.role,
  });

  factory RetrieveGroupResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveGroupResponseDto(
      id: json['groupId'],
      name: json['name'] as String? ,
      isMainGroup: json['isMainGroup'] ?? false,
      role: GroupRole.values[json['role'] ?? 0],
    );
  }

}
