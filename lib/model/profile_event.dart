

import 'package:wyd_front/model/enum/event_role.dart';

class ProfileEvent{
  String profileHash = "";
  EventRole role;
  bool confirmed = false;
  bool trusted = false;

  ProfileEvent(this.profileHash, this.role, this.confirmed, this.trusted);



  factory ProfileEvent.fromJson(Map<String, dynamic> json){
    return switch (json) {
      {
        'profileHash': String profileHash,
        'role': int? role,
        'confirmed': bool confirmed,
        'trusted': bool trusted
      } => ProfileEvent(
        profileHash,
        EventRole.values[role ?? 0],
        confirmed,
        trusted
      ), 
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