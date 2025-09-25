import 'package:wyd_front/API/User/retrieve_user_profile_response_dto.dart';
import 'package:wyd_front/model/profile.dart';

class RetrieveUserResponseDto {
  String hash = "";
  String currentProfileHash = "";
  //Accounts
  List<Profile> profiles = [];

  RetrieveUserResponseDto({
    this.hash = "",
    this.currentProfileHash = "",
    List<Profile>? profiles,
  }) : profiles = profiles ?? [];

  factory RetrieveUserResponseDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'hash': String? hash,
        'profiles': List<dynamic>? profiles,
      } =>
        RetrieveUserResponseDto(
          hash: hash ?? "",
          currentProfileHash: "",
          profiles: profiles != null
              ? profiles.map((profile) {
                  return Profile.fromUserDto(RetrieveUserProfileResponseDto.fromJson(profile as Map<String, dynamic>));
                }).toList()
              : <Profile>[],
        ),
      _ => throw const FormatException('Failed to decode UserDto')
    };
  }
}
