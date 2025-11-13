import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/API/Profile/retrieve_profile_response_dto.dart';
import 'package:wyd_front/API/Profile/update_profile_request_dto.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/profile_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class ProfileAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}/wyd/api/Profile/';

  final InterceptedClient client;

  ProfileAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
          ProfileInterceptor(),
        ]);

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
  Future<List<RetrieveProfileResponseDto>> retrieveFromHashes(List<String> profileHashes) async {
    String url = '${functionUrl}Retrieve';

    var response = await client.post(Uri.parse(url), body: jsonEncode(profileHashes));

    if (response.statusCode == 200) {
      List<dynamic> parsedJson = json.decode(response.body);
      var profiles =
          parsedJson.map((profile) => RetrieveProfileResponseDto.fromJson(profile as Map<String, dynamic>)).toList();

      return profiles;
    }

    throw "Error while fetching the profile";
  }

  Future<List<RetrieveProfileResponseDto>> retrieveRoles() async {
    String url = '${functionUrl}RetrieveRoles';

    var response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> parsedJson = json.decode(response.body);
      var profiles =
          parsedJson.map((profile) => RetrieveProfileResponseDto.fromJson(profile as Map<String, dynamic>)).toList();

      return profiles;
    }

    throw "Error while fetching the profile roles";
  }

  Future<List<RetrieveProfileResponseDto>> searchByTag(String searchTag) async {
    String url = '${functionUrl}SearchbyTag';

    var response = await client.get(
      Uri.parse('$url/$searchTag'),
    );

    if (response.statusCode == 200) {
      var profiles = List<RetrieveProfileResponseDto>.from(
          json.decode(response.body).map((profile) => RetrieveProfileResponseDto.fromJson(profile)));
      return profiles;
    } else {
      return List.empty();
    }
  }

  Future<RetrieveProfileResponseDto> updateProfile(UpdateProfileRequestDto updateDto) async {
    String url = '${functionUrl}Update';

    var response = await client.post(Uri.parse(url), body: jsonEncode(updateDto));

    if (response.statusCode == 200) {
      return RetrieveProfileResponseDto.fromJson(json.decode(response.body));
    }

    throw "Error while updating the profile";
  }

  Future<RetrieveProfileResponseDto> retrieveDetailed(String profileId) async {
    String url = '${functionUrl}RetrieveDetailed';

    var response = await client.get(Uri.parse('$url/$profileId'));

    if (response.statusCode == 200) {
      return RetrieveProfileResponseDto.fromJson(json.decode(response.body));
    }

    throw "Error while updating the profile";
  }
}
