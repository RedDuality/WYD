import 'package:wyd_front/model/enum/role.dart';

class RetrieveUserProfileResponseDto {
  final String id;
  final String tag;
  final String name;
  final DateTime updatedAt;
  final String? blobHash;
  final int? color;
  Role? role;
  bool? mainProfile = false;

  RetrieveUserProfileResponseDto({
    required this.id,
    required this.tag,
    required this.name,
    required this.updatedAt,
    this.blobHash,
    this.color,
    this.role,
    this.mainProfile,
  });

  factory RetrieveUserProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveUserProfileResponseDto(
      id: json['id'] as String,
      tag: json['tag'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      blobHash: json['blobHash'] as String?,
      color: json['color'] as int?,
      role: json['role'] != null ? Role.values[json['role']] : null,
      mainProfile: json['mainProfile'] as bool?,
    );
  }
}
