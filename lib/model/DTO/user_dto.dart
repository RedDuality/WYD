
import 'package:wyd_front/model/profile.dart';

class UserDto {
  int id = -1;
  String mail = "";
  String userName = "";
  String tag = "";

  UserDto({
    this.id = -1,
    this.mail = "",
    this.userName = "",
    this.tag = "",
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int? id,
        'mail': String? mail,
        'userName': String? username,
        'tag': String? tag,
      } =>
        UserDto(
          id: id ?? -1,
          mail: mail ?? "",
          userName: username ?? "",
          tag: tag ?? "",
        ),
      _ => throw const FormatException('Failed to decode UserDto')
    };
  }
}
