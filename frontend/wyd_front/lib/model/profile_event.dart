

import 'package:wyd_front/model/enum/event_role.dart';

class ProfileEvent{
  int profileId = -1;
  EventRole role;
  bool confirmed = false;
  bool trusted = false;

  ProfileEvent(this.profileId, this.role, this.confirmed, this.trusted);



  factory ProfileEvent.fromJson(Map<String, dynamic> json){
    return switch (json) {
      {
        'profileId': int profileId,
        'role': int? role,
        'confirmed': bool confirmed,
        'trusted': bool trusted
      } => ProfileEvent(
        profileId,
        EventRole.values[role ?? 0],
        confirmed,
        trusted
      ), 
      _ => throw const FormatException('Failed to decode ProfileEvent')
    };
  }

  
  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'confirmed': confirmed,
      'trusted': trusted,
      'eventRole': role.index,
    };
  }

}