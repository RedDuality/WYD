
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/profile.dart';

class User {
  int id = -1;
  String uid = "";
  String mainMail = "";
  String userName = "";
  List<Profile> profiles = [];
  //List<Account> accounts = [];
  //List<Group> groups = [];
  List<Community> communities = [];

  User({
    this.id = -1,
    this.uid = "",
    this.mainMail = "",
    this.userName = "",
    List<Profile>? profiles,
  }) : profiles = profiles ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int? id,
        'uid': String? uid,
        'mainMail': String? email,
        'userName': String? username,
        'userRoles': List<dynamic>? roles,
      } =>
        User(
          id: id ?? -1,
          uid: uid ?? "",
          mainMail: email ?? "",
          userName: username ?? "",
          profiles: roles != null
              ? roles.map((role) {
                  Profile p = Profile.fromJson(role as Map<String, dynamic>);
                  return p;
                }).toList()
              : <Profile>[],
        ),
      _ => throw const FormatException('Failed to decode User')
    };
  }
}
