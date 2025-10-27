import 'package:flutter/material.dart';
import 'package:wyd_front/API/Profile/retrieve_profile_response_dto.dart';
import 'package:wyd_front/model/enum/role.dart';

class Profile {
  String id = "";
  String tag = "";
  String name = "";
  DateTime lastFetched;
  DateTime updatedAt;
  String? blobHash = "";
  Color? color;
  Role role;
  bool mainProfile = false;

  
  Profile({
    this.id = "",
    this.tag = "",
    this.name = "",
    required this.lastFetched,
    required this.updatedAt,
    this.blobHash = "",
    this.color,
    this.role = Role.viewer,
    this.mainProfile = false,
  });

  factory Profile.fromDto(RetrieveProfileResponseDto dto) {
    return Profile(
      id: dto.id,
      tag: dto.tag!,
      name: dto.name!,
      lastFetched: DateTime.now(),
      updatedAt: dto.updatedAt!,
    );
  }

  factory Profile.fromUserDto(RetrieveProfileResponseDto dto) {
    return Profile(
      id: dto.id,
      tag: dto.tag!,
      name: dto.name!,
      lastFetched: DateTime.now(),
      updatedAt: dto.updatedAt!,
      blobHash: dto.blobHash,
      color: dto.color,
      role: dto.role ?? Role.viewer,
      mainProfile: dto.mainProfile ?? false,
    );
  }

/*
  Profile copyWith({
    String? name,
    String? tag,
    bool? mainProfile,
    String? blobHash,
    Color? color,
    ProfileType? type,
    Role? role,
    DateTime? updatedAt,
  }) {
    return Profile(
        id: id,
        name: name ?? this.name,
        tag: tag ?? this.tag,
        mainProfile: mainProfile ?? this.mainProfile,
        lastFetched: lastFetched,
        blobHash: blobHash ?? this.blobHash,
        color: color ?? this.color,
        role: role ?? this.role,
        updatedAt: updatedAt ?? this.updatedAt);
  }
*/
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'color': color?.toARGB32(),
    };
  }
}
