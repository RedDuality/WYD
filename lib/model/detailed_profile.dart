import 'dart:ui';

import 'package:wyd_front/API/Profile/retrieve_detailed_profile_response_dto.dart';

class DetailedProfile {
  String id;
  String tag;
  String name;
  Color? color;
  String? blobHash = "";

  DateTime lastFetched;
  DateTime? updatedAt;

  DetailedProfile({
    required this.id,
    required this.tag,
    required this.name,
    required this.lastFetched,
    required this.updatedAt,
    this.color,
    this.blobHash,
  });

  factory DetailedProfile.fromDto(RetrieveDetailedProfileResponseDto dto) {
    return DetailedProfile(
      id: dto.id,
      tag: dto.tag,
      name: dto.name,
      color: dto.color,
      lastFetched: DateTime.now(),
      updatedAt: dto.updatedAt,
    );
  }

  /// --- DB helpers ---
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'tag': tag,
      'name': name,
      'color': color?.toARGB32(),
      'blobHash': blobHash,
      'lastFetched': lastFetched.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory DetailedProfile.fromDbMap(Map<String, dynamic> map) {
    return DetailedProfile(
      id: map['id'] as String,
      tag: map['tag'] as String,
      name: map['name'] as String,
      color: map['color'] != null ? Color(map['color'] as int) : null,
      blobHash: map['blobHash'] as String?,
      lastFetched: DateTime.fromMillisecondsSinceEpoch(map['lastFetched'] as int),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  } 
}
