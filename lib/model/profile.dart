
import 'package:wyd_front/model/enum/profile_type.dart';
import 'package:wyd_front/model/enum/role.dart';

class Profile{
  int id = -1;
  ProfileType type;
  Role role;
  //List<Group> groups = [];

  Profile({this.id = -1, 
          this.type = ProfileType.personal, 
          this.role = Role.owner});

  

  // Factory constructor to create a Profile from JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'profile': Map<String, dynamic> profile,
        'role': int role,
      } =>
        Profile(
          id: profile['id'] ?? -1,
          type: ProfileType.values[profile['type'] ?? 0],
          role: Role.values[role],
        ),
      _ => throw const FormatException('Failed to decode Profile')
    };
/*
    debugPrint("");
    return Profile(
      id: json['profile']['id'] ?? -1,
      type: ProfileType.values[json['profile']['type'] ?? 0],
      role: Role.values[json['role'] ?? 0],
    );
  */}


    // Optional: toJson method if you need to convert Profile back to JSON
  Map<String, dynamic> toJson() {
    return {
      'profile': {
        'id': id,
        'type': type.index,
      },
      'role': role.index,
    };
  }
}
