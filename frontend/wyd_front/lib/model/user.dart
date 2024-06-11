
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/user_dto.dart';

class User{
  int id = -1;
  String mail = "";
  String username = "";
  List<Community> communities = [];

  User({this.id = -1, this.mail = "", this.username= "", this.communities=const []});

  User.fromDto(UserDto dto){
    id = dto.id;
    mail = dto.mail;
    username = dto.username;
    communities = dto.communities;
  }

  
  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'mail': String? email,
        'username': String? username,
        'id': int? id,
      } =>
        User(
            id: id?? -1,
            mail: email ?? "",
            username: username ?? "",
        ),
      _ => throw const FormatException('Failed to decode User')
    };
  }
}
