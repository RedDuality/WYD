
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/model/group.dart';

class Community {
  int id = 0;
  String name = "";
  String blobHash = "";
  CommunityType type = CommunityType.personal;
  List<Group> groups = [];

  Community({
    this.id = -1,
    this.name = "",
    this.blobHash = "",
    this.type = CommunityType.personal,
    List<Group>? groups,
  }) : groups = groups ?? [];

  factory Community.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id" : int id,
        "name" : String name,
        "blobHash": String? blobHash,
        "type" : int? type,
        "groups" : List<dynamic>? groups,
      } => Community(
        id : id, 
        name : name, 
        blobHash: blobHash ?? "",
        type : type != null ? CommunityType.values[type] : CommunityType.personal, 
        groups : groups != null ? groups.map((user) => Group.fromJson(user as Map<String,dynamic>)).toList() : <Group>[]
        ),
      _ => throw const FormatException('Failed to decode Community')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'blobHash': blobHash,
      'type': type.index,
      'groups': groups.map((user) => user.toJson()).toList(),
    };
  }


}
