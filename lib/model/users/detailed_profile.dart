import 'dart:convert';
import 'dart:ui';

import 'package:wyd_front/API/Profile/retrieve_detailed_profile_response_dto.dart';
import 'package:wyd_front/model/profiles/external_imports.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';

class DetailedProfile {
  String id;
  String tag;
  String name;
  DateTime lastFetched;
  DateTime? updatedAt;

  String? importedUserId;
  SignInPlatform importType;

  Color? color;
  String? blobHash = "";

  List<ExternalImports>? imports;

  DetailedProfile({
    required this.id,
    required this.tag,
    required this.name,
    required this.lastFetched,
    required this.updatedAt,
    this.importedUserId,
    required this.importType,
    this.color,
    this.blobHash,
    this.imports,
  });

  factory DetailedProfile.fromDto(RetrieveDetailedProfileResponseDto dto) {
    return DetailedProfile(
      id: dto.id,
      tag: dto.tag,
      name: dto.name,
      lastFetched: DateTime.now(),
      updatedAt: dto.updatedAt,
      importedUserId: dto.importedUserId,
      importType: SignInPlatform.fromString(dto.importType),
      color: dto.color,
      imports: dto.imports ?? [],
    );
  }

  /// --- DB helpers ---
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'tag': tag,
      'name': name,
      'color': color?.toARGB32(),
      'importedUser': importedUserId,
      'importType': importType.toString(),
      'blobHash': blobHash,
      'lastFetched': lastFetched.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'imports': imports != null ? jsonEncode(imports!.map((e) => e.toDbMap()).toList()) : null,
    };
  }

  factory DetailedProfile.fromDbMap(Map<String, dynamic> map) {
    return DetailedProfile(
      id: map['id'] as String,
      tag: map['tag'] as String,
      name: map['name'] as String,
      importedUserId: map['importedUser'] as String?,
      importType: SignInPlatform.fromString(map['importType'] as String),
      color: map['color'] != null ? Color(map['color'] as int) : null,
      blobHash: map['blobHash'] as String?,
      lastFetched: DateTime.fromMillisecondsSinceEpoch(map['lastFetched'] as int),
      updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int) : null,
      imports: map['imports'] != null
          ? (jsonDecode(map['imports'] as String) as List<dynamic>)
              .map((i) => ExternalImports.fromDbMap(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
