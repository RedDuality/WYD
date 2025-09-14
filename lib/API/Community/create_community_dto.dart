import 'package:wyd_front/model/enum/community_type.dart';

class CreateCommunityDto {
  int id = 0;
  String name = "Personal";
  CommunityType type = CommunityType.personal;
  List<String> profileHashes = [];

  CreateCommunityDto({
    this.id = -1,
    this.name = "Personal",
    this.type = CommunityType.personal,
    List<String>? hashes,
  }) : profileHashes = hashes ?? [];

/*
  factory CreateCommunityDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id" : int id,
        "name" : String name,
        "type" : int? type,
        "profiles" : List<String>? profileHashes,
      } => CreateCommunityDto(
        id : id, 
        name : name, 
        type : type != null ? CommunityType.values[type] : CommunityType.personal, 
        hashes : profileHashes ?? [],
        ),
      _ => throw const FormatException('Failed to decode community')
    };
  }
*/

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'profiles': profileHashes,
    };
  }
}
