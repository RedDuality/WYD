import 'dart:convert';

import 'package:wyd_front/API/user_api.dart';
import 'package:wyd_front/model/profile.dart';

class UserService {
  Future<List<Profile>?> searchByTag(String searchTag) async {
    var response = await UserAPI().searchByTag(searchTag);

    if (response.statusCode == 200) {
      List<Profile> users = List<Profile>.from(
          json.decode(response.body).map((profile) => Profile.fromJson(profile)));
      return users;
    } else {
      return null;
    }
  }
}
