import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class ProfileAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}Profile/';

  final InterceptedClient client;

  ProfileAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
        ]);

  Future<List<Profile>?> searchByTag(String searchTag) async {
    String url = '${functionUrl}SearchbyTag';

    var response = await client.get(
      Uri.parse('$url/$searchTag'),
    );

    if (response.statusCode == 200) {
      List<Profile> profiles = List<Profile>.from(json
          .decode(response.body)
          .map((profile) => Profile.fromJson(profile)));
      return profiles;
    } else {
      return null;
    }
  }

/*
  Future<Profile> retrieveFromHash(String profileHash) async {
    String url = '${functionUrl}Retrieve';
    var response = await client.get(Uri.parse('$url/$profileHash'));

    if (response.statusCode == 200) {
      var profile = Profile.fromJson(jsonDecode(response.body));
      return profile;
    }

    throw "Error while fetching the profile";
  }
*/
  Future<List<Profile>> retrieveFromHashes(List<String> profileHashes) async {
    String url = '${functionUrl}Retrieve';

    var response =
        await client.post(Uri.parse(url), body: jsonEncode(profileHashes));

    if (response.statusCode == 200) {
      List<dynamic> parsedJson = json.decode(response.body);
      List<Profile> profiles = parsedJson
          .map((profile) => Profile.fromJson(profile as Map<String, dynamic>))
          .toList();

      return profiles;
    }

    throw "Error while fetching the profile";
  }

  Future<List<Profile>> retrieveRoles() async {
    String url = '${functionUrl}RetrieveRoles';

    var response =
        await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> parsedJson = json.decode(response.body);
      List<Profile> profiles = parsedJson
          .map((profile) => Profile.fromJson(profile as Map<String, dynamic>))
          .toList();

      return profiles;
    }

    throw "Error while fetching the profile roles";
  }


  Future<void> updateProfile(Profile profile) async {
    String url = '${functionUrl}Update';

    var response = await client.post(Uri.parse(url), body: jsonEncode(profile));

    if (response.statusCode == 200) {
      return;
    }

    throw "Error while updating the profile";
  }
}
