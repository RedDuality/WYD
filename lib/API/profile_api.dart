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
      List<Profile> profiles = List<Profile>.from(
          json.decode(response.body).map((profile) => Profile.fromJson(profile)));
      return profiles;
    } else {
      return null;
    }
  }
}
