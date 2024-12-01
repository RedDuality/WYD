import 'dart:convert';

import 'package:wyd_front/API/user_api.dart';
import 'package:wyd_front/model/DTO/user_dto.dart';

class UserService {
  Future<List<UserDto>?> searchByTag(String searchTag) async {
    var response = await UserAPI().searchByTag(searchTag);

    if (response.statusCode == 200) {
      List<UserDto> users = List<UserDto>.from(
          json.decode(response.body).map((user) => UserDto.fromJson(user)));
      return users;
    } else {
      return null;
    }
  }
}
