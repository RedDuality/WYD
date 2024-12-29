import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/profile.dart';

class User {
  int id = -1;
  String hash = "";
  String mainProfileHash = "";
  List<Profile> profiles = [];

  User({
    this.id = -1,
    this.hash = "",
    this.mainProfileHash = "",
    List<Profile>? profiles,
    List<Community>? communities,
  })  : profiles = profiles ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int? id,
        'hash': String? hash,
        'mainProfileHash': String? mainProfileHash,
        'userRoles': List<dynamic>? roles,
      } =>
        User(
          id: id ?? -1,
          hash: hash ?? "",
          mainProfileHash: mainProfileHash ?? "",
          profiles: roles != null
              ? roles.map((role) {
                  Profile p = Profile.fromUserRoleJson(role as Map<String, dynamic>);
                  return p;
                }).toList()
              : <Profile>[],
        ),
      _ => throw const FormatException('Failed to decode User')
    };
  }
}
