import 'package:wyd_front/model/profile.dart';

class RetrieveUserDto {
  String hash = "";
  String currentProfileHash = "";
  //Accounts
  List<Profile> profiles = [];

  RetrieveUserDto({
    this.hash = "",
    this.currentProfileHash = "",
    List<Profile>? profiles,
  }) : profiles = profiles ?? [];

  factory RetrieveUserDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'hash': String? hash,
        'mainProfileHash': String? mainProfileHash,
        'profiles': List<dynamic>? profiles,
      } =>
        RetrieveUserDto(
          hash: hash ?? "",
          currentProfileHash: mainProfileHash ?? "",
          profiles: profiles != null
              ? profiles.map((profile) {
                  return Profile.fromJson(profile as Map<String, dynamic>);
                }).toList()
              : <Profile>[],
        ),
      _ => throw const FormatException('Failed to decode UserDto')
    };
  }
}
