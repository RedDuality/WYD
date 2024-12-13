import 'dart:convert';

import 'package:wyd_front/API/profile_api.dart';
import 'package:wyd_front/model/profile.dart';

class ProfileService {
  Future<List<Profile>?> searchByTag(String searchTag) async {
    var response = await ProfileAPI().searchByTag(searchTag);

    if (response.statusCode == 200) {
      List<Profile> users = List<Profile>.from(
          json.decode(response.body).map((profile) => Profile.fromJson(profile)));
      return users;
    } else {
      return null;
    }
  }
}
