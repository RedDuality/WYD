import 'package:flutter/material.dart';

class Group {
  int id;
  String hash;
  String name;
  Color color;
  bool trusted;
  bool generalForCommunity;
  Set<String> profileHashes;

  Group({
    this.id = 0,
    this.name = "",
    this.hash = "",
    this.color = Colors.white,
    this.trusted = false,
    this.generalForCommunity = false,
    Set<String>? profileHashes,
  }) : profileHashes = profileHashes ?? {};

  factory Group.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int? id,
        "name": String? name,
        "hash": String? hash,
        "color": int? color,
        "trusted": bool? trusted,
        "generalForCommunity": bool? generalForCommunity,
        "profileHashes": List<dynamic>? profiles,
      } =>
        Group(
          id: id ?? 0,
          name: name ?? "",
          hash: hash ?? "",
          color: color != null ? Color(color) : Colors.green,
          trusted: trusted ?? false,
          generalForCommunity: generalForCommunity ?? false,
          profileHashes: profiles?.map((e) => e as String).toSet() ?? {},
        ),
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
      'profileHashes': profileHashes,
    };
  }
}
