import 'package:wyd_front/API/Profile/retrieve_profile_response_dto.dart';
import 'package:wyd_front/model/detailed_profile.dart';

class Profile {
  String id = "";
  String tag = "";
  String name = "";
  String? blobHash = "";

  DateTime lastFetched;
  DateTime updatedAt;

  Profile({
    this.id = "",
    this.tag = "",
    this.name = "",
    required this.lastFetched,
    required this.updatedAt,
    this.blobHash = "",
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

  factory Profile.fromDetailed(DetailedProfile dp) {
    return Profile(
      id: dp.id,
      tag: dp.tag,
      name: dp.name,
      blobHash: dp.blobHash,
      lastFetched: dp.lastFetched,
      updatedAt: dp.updatedAt!,
    );
  }

  /// Converts a Profile object to a Map for SQLite.
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'tag': tag,
      'name': name,
      'lastFetched': lastFetched.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'blobHash': blobHash,
    };
  }

  /// Converts a DB map back into a Profile object.
  factory Profile.fromDbMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? "",
      tag: map['tag'] ?? "",
      name: map['name'] ?? "",
      lastFetched: DateTime.fromMillisecondsSinceEpoch(map['lastFetched']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      blobHash: map['blobHash'],
    );
  }
}
