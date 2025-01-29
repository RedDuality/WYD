import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/profile_type.dart';
import 'package:wyd_front/model/enum/role.dart';

class Profile {
  String hash = "";
  String tag = "";
  String name = "";
  String? blobHash = "";
  Color? color;
  ProfileType type;
  Role? role;

  Profile(
      {this.name = "",
      this.hash = "",
      this.tag = "",
      this.blobHash = "",
      this.color,
      this.type = ProfileType.personal,
      this.role = Role.viewer});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile && other.hash == hash;
  }

  @override
  int get hashCode => hash.hashCode;

  // Factory constructor to create a Profile from JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'name': String? name,
        'hash': String? hash,
        'tag': String? tag,
        'blobHash': String? blobHash,
        'type': int? type,
        'role': int? role,
        'color': int? color,
      } =>
        Profile(
          name: name ?? "",
          hash: hash ?? "",
          tag: tag ?? "",
          blobHash: blobHash ?? "",
          type: ProfileType.values[type ?? 0],
          color: color != null ? Color(color) : null,
          role: role != null ? Role.values[role] : Role.viewer,
        ),
      _ => throw const FormatException('Failed to decode Profile')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'name': name,
      'tag': tag,
      'color': color?.value,
    };
  }
}
