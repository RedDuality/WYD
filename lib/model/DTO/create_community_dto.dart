
import 'package:wyd_front/model/enum/community_type.dart';

class CreateCommunityDto {
  int id = 0;
  String name = "Personal";
  CommunityType type = CommunityType.personal;
  List<int> profileIds = [];

  CreateCommunityDto({
    this.id = -1,
    this.name = "Personal",
    this.type = CommunityType.personal,
    List<int>? ids,
  }) : profileIds = ids ?? [];

  factory CreateCommunityDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id" : int id,
        "name" : String name,
        "type" : int? type,
        "profiles" : List<int>? profileIds,
      } => CreateCommunityDto(
        id : id, 
        name : name, 
        type : type != null ? CommunityType.values[type] : CommunityType.personal, 
        ids : profileIds ?? [],
        ),
      _ => throw const FormatException('Failed to decode community')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'profiles': profileIds,
    };
  }


}
