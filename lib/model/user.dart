import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/profile.dart';

class User {
  int id = -1;
  String hash = "";
  String mainMail = "";
  String userName = "";
  String tag = "";
  int mainProfileId = -1;
  List<Profile> profiles = [];
  List<Community> communities = [];

  User({
    this.id = -1,
    this.hash = "",
    this.mainMail = "",
    this.userName = "",
    this.tag = "",
    this.mainProfileId = -1,
    List<Profile>? profiles,
    List<Community>? communities,
  })  : profiles = profiles ?? [],
        communities = communities ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int? id,
        'hash': String? hash,
        'mainMail': String? email,
        'userName': String? username,
        'tag': String? tag,
        'mainProfileId': int? mainProfileId,
        'userRoles': List<dynamic>? roles,
        'communities': List<dynamic>? communities,
      } =>
        User(
          id: id ?? -1,
          hash: hash ?? "",
          mainMail: email ?? "",
          userName: username ?? "",
          tag: tag ?? "",
          mainProfileId: mainProfileId ?? -1,
          profiles: roles != null
              ? roles.map((role) {
                  Profile p = Profile.fromJson(role as Map<String, dynamic>);
                  return p;
                }).toList()
              : <Profile>[],
          communities: communities != null
              ? communities
                  .map((community) =>
                      Community.fromJson(community as Map<String, dynamic>))
                  .toList()
              : <Community>[],
        ),
      _ => throw const FormatException('Failed to decode User')
    };
  }
}
