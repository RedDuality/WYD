import 'package:wyd_front/model/enum/event_role.dart';

class ProfileEvent {
  String eventId;
  String profileId;
  EventRole role;
  bool confirmed;
  bool trusted;

  ProfileEvent({
    required this.eventId,
    required this.profileId,
    this.role = EventRole.viewer,
    this.confirmed = false,
    this.trusted = false,
  });

  @override
  int get hashCode => Object.hash(eventId, profileId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileEvent && other.eventId == eventId && other.profileId == profileId;
  }

  Map<String, dynamic> toDbMap() => {
        'eventId': eventId,
        'profileHash': profileId,
        'role': role.index,
        'confirmed': confirmed ? 1 : 0,
        'trusted': trusted,
      };

  static ProfileEvent fromDbMap(Map<String, dynamic> map) {
    return ProfileEvent(
      eventId: map['eventId'],
      profileId: map['profileId'],
      role: EventRole.values[map['role']],
      confirmed: map['confirmed'] == 1,
      trusted: map['trusted'] == 1,
    );
  }

  factory ProfileEvent.fromJson(String eventId, Map<String, dynamic> json) {
    return ProfileEvent(
      eventId: eventId,
      profileId: json['profileId'] as String,
      role: EventRole.values[json['role'] ?? 0],
      confirmed: json['confirmed'] as bool,
      trusted: json['trusted'] as bool,
    );
  }

  /*
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'profileId': profileId,
      'eventRole': role.index,
      'confirmed': confirmed,
      'trusted': trusted,
    };
  }*/
}
