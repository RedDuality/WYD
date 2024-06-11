


import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/my_event.dart';

class UserDto{
  int id = -1;
  String mail = "";
  String username = "";
  List<Community> communities = [];
  List<MyEvent> events = []; 

  UserDto({this.id = -1, this.mail = "", this.username = "", this.communities = const [], this.events = const [] });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'mail': String? email,
        'username': String? username,
        'id': int? id,
        'communities': List<dynamic>? communities,
        'events': List<dynamic>? events,
      } =>
        UserDto(
            id: id?? -1,
            mail: email ?? "",
            username: username ?? "",
            communities: communities != null ? communities.map((community) => Community.fromJson(community as Map<String, dynamic>)).toList() : <Community>[],
            events: events != null ? events.map((event) => MyEvent.fromJson(event as Map<String, dynamic> )).toList() : <MyEvent>[],
        ),
      _ => throw const FormatException('Failed to decode UserDto')
    };
  }
}
