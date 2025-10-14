import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';
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

  User.fromDto(RetrieveUserResponseDto dto) {
    hash = dto.hash;
    profileHashes = dto.profiles.map((profile) => profile.id).toSet();
    currentProfileHash =
        dto.profiles.firstWhere(
          (profile) => profile.mainProfile == true,
          orElse: () => dto.profiles.firstWhere((profile) => profile.role == Role.owner,),
        ).id;
  }
}
