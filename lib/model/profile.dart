import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/profile_type.dart';
import 'package:wyd_front/model/enum/role.dart';

class Profile {
  String hash = "";
  String tag = "";
  String name = "";
  bool mainProfile = false;
  String? blobHash = "";
  Color? color;
  //ProfileType type;
  Role? role;
  DateTime lastUpdatedTime;

//TODO mettere il default profile

  Profile({
    this.name = "",
    this.hash = "",
    this.tag = "",
    this.mainProfile = false,
    this.blobHash = "",
    this.color,
    //this.type = ProfileType.personal,
    this.role = Role.viewer,
  }) : lastUpdatedTime = DateTime.now();

  Profile copyWith({
    String? name,
    String? tag,
    bool? mainProfile,
    String? blobHash,
    Color? color,
    ProfileType? type,
    Role? role,
    DateTime? lastUpdatedTime,
  }) {
    return Profile(
        hash: hash,
        name: name ?? this.name,
        tag: tag ?? this.tag,
        mainProfile: mainProfile ?? this.mainProfile,
        blobHash: blobHash ?? this.blobHash,
        color: color ?? this.color,
        //type: type ?? this.type,
        role: role ?? this.role);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.hash == hash &&
        other.lastUpdatedTime == lastUpdatedTime;
  }

  @override
  int get hashCode => hash.hashCode;

  // Factory constructor to create a Profile from JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'hash': String? hash,
        'tag': String? tag,
        'name': String? name,
        'mainProfile': bool? mainProfile,
        'blobHash': String? blobHash,
        //'type': int? type,
        'role': int? role,
        'color': int? color,
      } =>
        Profile(
            hash: hash ?? "",
            tag: tag ?? "",
            name: name ?? "",
            mainProfile: mainProfile ?? false,
            blobHash: blobHash ?? "",
            //type: ProfileType.values[type ?? 0],
            color: color != null ? Color(color) : null,
            role: role != null ? Role.values[role] : Role.viewer),
      _ => throw const FormatException('Failed to decode Profile')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'name': name,
      'tag': tag,
      'color': color?.toARGB32(),
    };
  }
}
