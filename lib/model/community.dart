
import 'package:wyd_front/API/Community/retrieve_community_response_dto.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/model/group.dart';

class Community {
  String id;
  String? name;
  CommunityType type;
  DateTime updatedAt;
  String? otherProfileId;
  List<Group> groups = [];
  //profileHashes

  Community({
    required this.id,
    this.name,
    required this.type,
    required this.updatedAt,
    this.otherProfileId,
    List<Group>? groups,
  }) : groups = groups ?? [];


  String getProfileHash(){
    if(type != CommunityType.personal){
      throw "Personal profile looked for in a non-personal community";
    }
    return otherProfileId!;
  }

  factory Community.fromDto(RetrieveCommunityResponseDto dto){

    return Community(
      id: dto.id,
      name: dto.name,
      type: dto.type,
      updatedAt: dto.updatedAt,
      otherProfileId: dto.otherProfileId,
      groups: dto.groups.map((gdto) => Group.fromDto(gdto)).toList(),
    );

  }


}
