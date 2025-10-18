import 'dart:ui';

import 'package:wyd_front/model/enum/role.dart';

class RetrieveProfileResponseDto {
  final String id;
  final String? tag;
  final String? name;
  final DateTime? updatedAt;
  final String? blobHash;
  final Color? color;
  Role? role;
  bool? mainProfile = false;

  RetrieveProfileResponseDto({
    required this.id,
    this.tag,
    this.name,
    this.updatedAt,
    this.blobHash,
    this.color,
    this.role,
    this.mainProfile,
  });

  factory RetrieveProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveProfileResponseDto(
      id: json['id'] as String,
      tag: json['tag'] as String?,
      name: json['name'] as String?,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      blobHash: json['blobHash'] as String?,
      color: json['color'] != null ? Color(json['color']) : null,
      role: json['role'] != null ? Role.values[json['role']] : null,
      mainProfile: json['mainProfile'] as bool?,
    );
  }
}
