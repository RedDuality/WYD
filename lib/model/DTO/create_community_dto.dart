import 'package:wyd_front/model/DTO/user_dto.dart';
import 'package:wyd_front/model/enum/community_type.dart';

class CreateCommunityDto {
  int id = 0;
  String name = "";
  CommunityType type = CommunityType.personal;
  List<UserDto> users = [];

  CreateCommunityDto({
    this.id = -1,
    this.name = "",
    this.type = CommunityType.personal,
    List<UserDto>? users,
  }) : users = users ?? [];

  factory CreateCommunityDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id" : int id,
        "name" : String name,
        "type" : int? type,
        "users" : List<dynamic>? users,
      } => CreateCommunityDto(
        id : id, 
        name : name, 
        type : type != null ? CommunityType.values[type] : CommunityType.personal, 
        users : users != null ? users.map((user) => UserDto.fromJson(user as Map<String,dynamic>)).toList() : <UserDto>[]
        ),
      _ => throw const FormatException('Failed to decode community')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }


}
