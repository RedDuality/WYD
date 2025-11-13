import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/API/Community/create_community_request_dto.dart';
import 'package:wyd_front/API/Community/retrieve_community_response_dto.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/profile_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class CommunityAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}/wyd/api/Community/';

  final InterceptedClient client;

  CommunityAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
          ProfileInterceptor(),
        ]);

  Future<List<RetrieveCommunityResponseDto>> retrieveCommunities() async {
    String url = '${functionUrl}Retrieve';

    var response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> parsedJson = json.decode(response.body);
      List<RetrieveCommunityResponseDto> communities = parsedJson
          .map((community) => RetrieveCommunityResponseDto.fromJson(community as Map<String, dynamic>))
          .toList();

      return communities;
    } else {
      debugPrint("Error while retrieving the community, please retry later");
      return [];
    }
  }

  Future<RetrieveCommunityResponseDto> create(CreateCommunityRequestDto community) async {
    String url = '${functionUrl}Create';

    var response = await client.post(
      Uri.parse(url),
      body: jsonEncode(community),
    );

    if (response.statusCode == 200) {
      var newCommunity = RetrieveCommunityResponseDto.fromJson(jsonDecode(response.body));
      return newCommunity;
    } else {
      throw "Error while creating the community, please retry later";
    }
  }

/*
  Future<Response> update(int communityId, CommunityDto community) async {
    String url = '${functionUrl}Update';

    return client.post(
      Uri.parse('$url/$communityId'),
      body: jsonEncode(community),
    );
  }
*/
}
