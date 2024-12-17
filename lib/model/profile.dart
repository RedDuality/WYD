import 'package:wyd_front/model/enum/profile_type.dart';
import 'package:wyd_front/model/enum/role.dart';

class Profile {
  int id = 0;
  String name = "";
  String hash = "";
  String tag = "";
  String? blobHash = "";
  ProfileType type;
  Role? role;

  Profile(
      {this.id = 0,
      this.name = "",
      this.hash = "",
      this.tag = "",
      this.blobHash = "",
      this.type = ProfileType.personal,
      this.role = Role.owner});

  // Factory constructor to create a Profile from JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int? id,
        'name': String? name,
        'hash': String? hash,
        'tag': String? tag,
        'blobHash': String? blobHash,
        'type': int? type,
      } =>
        Profile(
          id: id ?? 0,
          name: name ?? "",
          hash: hash ?? "",
          tag: tag ?? "",
          blobHash: blobHash ?? "",
          type: ProfileType.values[type ?? 0],
        ),
      _ => throw const FormatException('Failed to decode Profile')
    };
  }
  factory Profile.fromUserRoleJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'profile': Map<String, dynamic> profile,
        'role': int role,
      } =>
        Profile(
          id: profile['id'] ?? 0,
          name: profile['name'] ?? "",
          hash: profile['hash'] ?? "",
          tag: profile['tag'] ?? "",
          blobHash: profile['blobHash'] ?? "",
          type: ProfileType.values[profile['type'] ?? 0],
          role: Role.values[role],
        ),
      _ => throw const FormatException('Failed to decode Profile from UserRole')
    };
  }
  // Optional: toJson method if you need to convert Profile back to JSON
  Map<String, dynamic> toJson() {
    return {
      'profile': {
        'id': id,
        'type': type.index,
        'hash': hash,
      },
      'role': role?.index,
    };
  }
}
