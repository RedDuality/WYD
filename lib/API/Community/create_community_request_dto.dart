import 'package:wyd_front/model/enum/community_type.dart';

class CreateCommunityRequestDto {
  String? name;
  CommunityType type;
  List<String> profileHashes = [];

  CreateCommunityRequestDto({
    this.name,
    this.type = CommunityType.personal,
    List<String>? hashes,
  }) : profileHashes = hashes ?? [];


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.index,
      'profileIds': profileHashes,
    };
  }
}
