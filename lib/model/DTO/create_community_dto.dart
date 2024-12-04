
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/model/profile.dart';

class CreateCommunityDto {
  int id = 0;
  String name = "";
  CommunityType type = CommunityType.personal;
  List<Profile> users = [];

  CreateCommunityDto({
    this.id = -1,
    this.name = "",
    this.type = CommunityType.personal,
    List<Profile>? users,
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
        users : users != null ? users.map((user) => Profile.fromJson(user as Map<String,dynamic>)).toList() : <Profile>[]
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
