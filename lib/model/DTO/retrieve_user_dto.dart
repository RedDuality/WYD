import 'package:wyd_front/model/profile.dart';

class RetrieveUserDto {
  int id = -1;
  String hash = "";
  String currentProfileHash = "";
  //Accounts
  List<Profile> profiles = [];

  RetrieveUserDto({
    this.id = -1,
    this.hash = "",
    this.currentProfileHash = "",
    List<Profile>? profiles,
  }) : profiles = profiles ?? [];

  factory RetrieveUserDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int? id,
        'hash': String? hash,
        'mainProfileHash': String? mainProfileHash,
        'profiles': List<dynamic>? profiles,
      } =>
        RetrieveUserDto(
          id: id ?? -1,
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
