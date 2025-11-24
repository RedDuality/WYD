import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';

class User {
  String id = "";
  String mainProfileId = "";
  String currentProfileHash = "";
  Set<String> profileIds = {};

  User({required this.id, required this.currentProfileHash, required this.mainProfileId, required this.profileIds});

  User.fromDto(RetrieveUserResponseDto dto) {
    id = dto.id;
    mainProfileId = dto.mainProfileId;
    currentProfileHash = dto.mainProfileId;
    profileIds = dto.profileIds;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mainProfileId': mainProfileId,
      'currentProfileHash': currentProfileHash,
      // Sets aren’t directly JSON-serializable, so convert to List
      'profileIds': profileIds.toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] ?? "",
        mainProfileId: json['mainProfileId'] ?? "",
        currentProfileHash: json['currentProfileHash'] ?? "",
        profileIds: Set<String>.from(json['profileIds'] ?? []));
  }
}
