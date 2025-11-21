import 'package:wyd_front/API/Profile/retrieve_detailed_profile_response_dto.dart';

class RetrieveUserResponseDto {
  String id = "";
  String mainProfileId = "";
  Set<String> profileIds = {};
  // Accounts
  List<RetrieveDetailedProfileResponseDto> profiles = [];

  RetrieveUserResponseDto({
    required this.id,
    required this.mainProfileId,
    required this.profileIds,
    required this.profiles,
  });

factory RetrieveUserResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveUserResponseDto(
      id: json['id'] as String,
      mainProfileId: json['mainProfileId'] as String,
      profileIds: (json['profileIds'] as List<dynamic>)
          .map((e) => e as String)
          .toSet(),
      profiles: (json['profiles'] as List<dynamic>)
          .map((e) => RetrieveDetailedProfileResponseDto.fromJson(e))
          .toList(),
    );
  }
}
