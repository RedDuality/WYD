import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/profile_type.dart';
import 'package:wyd_front/model/enum/role.dart';

class Profile {
  String eventHash = "";
  String tag = "";
  String name = "";
  String? blobHash = "";
  Color? color;
  ProfileType type;
  Role? role;
  DateTime lastUpdatedTime;

  Profile({
    this.name = "",
    this.eventHash = "",
    this.tag = "",
    this.blobHash = "",
    this.color,
    this.type = ProfileType.personal,
    this.role = Role.viewer,
  }) : lastUpdatedTime = DateTime.now();

  Profile copyWith({
    String? name,
    String? tag,
    String? blobHash,
    Color? color,
    ProfileType? type,
    Role? role,
    DateTime? lastUpdatedTime,
  }) {
    return Profile(
        eventHash: eventHash,
        name: name ?? this.name,
        tag: tag ?? this.tag,
        blobHash: blobHash ?? this.blobHash,
        color: color ?? this.color,
        type: type ?? this.type,
        role: role ?? this.role);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.eventHash == eventHash &&
        other.lastUpdatedTime == lastUpdatedTime;
  }

  @override
  int get hashCode => eventHash.hashCode;

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
            eventHash: hash ?? "",
            tag: tag ?? "",
            blobHash: blobHash ?? "",
            type: ProfileType.values[type ?? 0],
            color: color != null ? Color(color) : null,
            role: role != null ? Role.values[role] : Role.viewer),
      _ => throw const FormatException('Failed to decode Profile')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': eventHash,
      'name': name,
      'tag': tag,
      'color': color?.value,
    };
  }
}
