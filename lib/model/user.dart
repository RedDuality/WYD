

import 'package:wyd_front/model/DTO/retrieve_user_dto.dart';

class User {
  int id = -1;
  String hash = "";
  String currentProfileHash = "";
  Set<String> profileHashes = {};

  User({
    this.id = -1,
    this.hash = "",
    this.currentProfileHash = "",
    Set<String>? profileHashes,
  }) : profileHashes = profileHashes ?? {};

  User.fromDto(RetrieveUserDto dto){
    id= dto.id;
    hash = dto.hash;
    currentProfileHash = dto.currentProfileHash;
    profileHashes = dto.profiles.map((profile) => profile.hash).toSet();
  }

}
