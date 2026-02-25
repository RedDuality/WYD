import 'package:flutter/material.dart';
import 'package:wyd_front/model/profiles/external_imports.dart';
import 'package:wyd_front/model/users/user_claim.dart';
import 'package:wyd_front/model/users/view_settings.dart';

class RetrieveDetailedProfileResponseDto {
  final String id;
  final String tag;
  final String name;
  final DateTime updatedAt;

  final String? importedUserId;
  final String? importType;

  final Color color;

  final List<ExternalImports>? imports;
  final List<ViewSettings>? viewSettings;
  final List<UserClaim>? userClaims;

  RetrieveDetailedProfileResponseDto({
    required this.id,
    required this.tag,
    required this.name,
    required this.updatedAt,
    this.importedUserId,
    this.importType,
    required this.color,
    this.imports,
    this.viewSettings,
    this.userClaims,
  }) ;

  factory RetrieveDetailedProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveDetailedProfileResponseDto(
      id: json['id'] as String,
      tag: json['tag'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
      importedUserId: json['importedUser'] as String?,
      importType: json['importType'] as String?,
      color: json['color'] != null ? Color(json['color']) : Colors.blue,
      viewSettings: (json['viewSettings'] as List<dynamic>?)
          ?.map((e) => ViewSettings.fromJson(json['id'], e as Map<String, dynamic>))
          .toList(),
      userClaims:
          (json['userClaims'] as List<dynamic>?)?.map((e) => UserClaim.fromJson(json['id'], e as String)).toList(),
      imports: (json['imports'] as List<dynamic>?)?.map((i) => ExternalImports.fromJson(i)).toList(),
    );
  }
}
