import 'package:flutter/material.dart';
import 'package:wyd_front/model/DTO/user_dto.dart';

class Group {
  int id;
  String name;
  String hash;
  Color color;
  bool trusted;
  bool generalForCommunity;
  List<UserDto> users;

  Group({
    this.id = 0,
    this.name = "",
    this.hash = "",
    this.color = Colors.white,
    this.trusted = false,
    this.generalForCommunity = false,
    List<UserDto>? users,
  }) : users = users ?? [];

  factory Group.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int? id,
        "name": String? name,
        "hash": String? hash,
        "color": int? color,
        "trusted": bool? trusted,
        "generalForCommunity": bool? generalForCommunity,
        "users": List<dynamic>? users,
      } =>
        Group(
            id: id ?? 0,
            name: name ?? "",
            hash: hash ?? "",
            color: color != null
                ? Color(color)
                : Colors.green,
            trusted: trusted ?? false,
            generalForCommunity: generalForCommunity ?? false,
            users: users != null
                ? users
                    .map((user) =>
                        UserDto.fromJson(user as Map<String, dynamic>))
                    .toList()
                : <UserDto>[]),
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
      'generalForCommunity' : generalForCommunity,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}
