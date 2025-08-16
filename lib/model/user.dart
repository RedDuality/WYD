

import 'package:wyd_front/model/DTO/retrieve_user_dto.dart';

class User {
  String hash = "";
  String currentProfileHash = "";
  Set<String> profileHashes = {};

  User({
    this.hash = "",
    this.currentProfileHash = "",
    Set<String>? profileHashes,
  }) : profileHashes = profileHashes ?? {};

  User.fromDto(RetrieveUserDto dto){
    hash = dto.hash;
    currentProfileHash = dto.currentProfileHash;
    profileHashes = dto.profiles.map((profile) => profile.hash).toSet();
  }

}