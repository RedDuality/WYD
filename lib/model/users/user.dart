import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';

class User {
  String id = "";
  String mainProfileId = "";
  String currentProfileId = "";
  Set<String> profileIds = {};

  User({required this.id, required this.currentProfileId, required this.mainProfileId, required this.profileIds});

  User.fromDto(RetrieveUserResponseDto dto) {
    id = dto.id;
    mainProfileId = dto.mainProfileId;
    currentProfileId = dto.mainProfileId;
    profileIds = dto.profileIds;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mainProfileId': mainProfileId,
      'currentProfileHash': currentProfileId,
      // Sets aren’t directly JSON-serializable, so convert to List
      'profileIds': profileIds.toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] ?? "",
        mainProfileId: json['mainProfileId'] ?? "",
        currentProfileId: json['currentProfileHash'] ?? "",
        profileIds: Set<String>.from(json['profileIds'] ?? []));
  }
}
