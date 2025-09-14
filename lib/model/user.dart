import 'package:wyd_front/API/User/retrieve_user_dto.dart';
import 'package:wyd_front/model/enum/role.dart';

class User {
  String hash = "";
  String currentProfileHash = "";
  Set<String> profileHashes = {};

  User({
    this.hash = "",
    this.currentProfileHash = "",
    Set<String>? profileHashes,
  }) : profileHashes = profileHashes ?? {};

  User.fromDto(RetrieveUserDto dto) {
    hash = dto.hash;
    profileHashes = dto.profiles.map((profile) => profile.hash).toSet();
    currentProfileHash =
        dto.profiles.firstWhere(
          (profile) => profile.mainProfile == true,
          orElse: () => dto.profiles.firstWhere((profile) => profile.role == Role.owner,),
        ).hash;
  }
}
