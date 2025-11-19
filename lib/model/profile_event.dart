import 'package:wyd_front/model/enum/event_role.dart';

class ProfileEvent {
  String profileHash = "";
  EventRole role;
  bool confirmed = false;
  bool trusted = false;

  ProfileEvent(this.profileHash, this.role, this.confirmed, this.trusted);

  @override
  int get hashCode => profileHash.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileEvent && other.profileHash == profileHash;
  }

  Map<String, dynamic> toDbMap(String eventHash) => {
        'eventHash': eventHash,
        'profileHash': profileHash,
        'confirmed': confirmed ? 1 : 0,
        'role': role,
        'trusted': trusted, // assuming role is a string
      };

  static ProfileEvent fromDbMap(Map<String, dynamic> map) => ProfileEvent(
        map['profileHash'],
        map['role'],
        map['confirmed'] == 1,
        map['trusted'] == 1,
      );

  factory ProfileEvent.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'profileHash': String profileHash,
        'role': int? role,
        'confirmed': bool confirmed,
        'trusted': bool trusted,
      } =>
        ProfileEvent(profileHash, EventRole.values[role ?? 0], confirmed, trusted),
      _ => throw const FormatException('Failed to decode ProfileEvent')
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'profileHash': profileHash,
      'confirmed': confirmed,
      'trusted': trusted,
      'eventRole': role.index,
    };
  }
}
