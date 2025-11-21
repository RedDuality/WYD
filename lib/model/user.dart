import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';

class User {
  String id = "";
  String mainProfileId = "";
  String currentProfileHash = "";
  Set<String> profileIds = {};

  User({
    required this.id,
    required this.currentProfileHash,
    required this.mainProfileId,
    required this.profileIds
  });

  User.fromDto(RetrieveUserResponseDto dto) {
    id = dto.id;
    mainProfileId = dto.mainProfileId;
    currentProfileHash = dto.mainProfileId;
    profileIds = dto.profileIds;
  }
}
