import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';

class Group {
  int id;
  String hash;
  String name;
  Color color;
  bool trusted;
  bool generalForCommunity;
  List<Profile> profiles;

  Group({
    this.id = 0,
    this.name = "",
    this.hash = "",
    this.color = Colors.white,
    this.trusted = false,
    this.generalForCommunity = false,
    List<Profile>? profiles,
  }) : profiles = profiles ?? [];

  factory Group.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int? id,
        "name": String? name,
        "hash": String? hash,
        "color": int? color,
        "trusted": bool? trusted,
        "generalForCommunity": bool? generalForCommunity,
        "profiles": List<dynamic>? profiles,
      } =>
        Group(
            id: id ?? 0,
            name: name ?? "",
            hash: hash ?? "",
            color: color != null ? Color(color) : Colors.green,
            trusted: trusted ?? false,
            generalForCommunity: generalForCommunity ?? false,
            profiles: profiles != null
                ? profiles
                    .map((profile) =>
                        Profile.fromJson(profile as Map<String, dynamic>))
                    .toList()
                : <Profile>[]),
      _ => throw const FormatException('Failed to decode group')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hash': hash,
      'color': color.value,
      'trusted': trusted,
      'generalForCommunity': generalForCommunity,
      'profiles': profiles.map((profile) => profile.toJson()).toList(),
    };
  }
}
