
import 'package:wyd_front/API/Community/retrieve_group_response_dto.dart';
import 'package:wyd_front/model/enum/group_role.dart';

class Group {
  String id;
  String? name;
  bool isMainGroup;
  GroupRole role;

  Group({
    required this.id,
    this.name,
    required this.isMainGroup,
    required this.role,
  });

  factory Group.fromDto(RetrieveGroupResponseDto dto){
    return Group(
      id: dto.id,
      name: dto.name,
      isMainGroup: dto.isMainGroup,
      role: dto.role,
    );
  }
}
