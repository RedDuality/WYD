import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/model/DTO/create_community_dto.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/util/auth_interceptor.dart';

class CommunityAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}Community/';

  final InterceptedClient client;

  CommunityAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
        ]);

  Future<Response> retrieveCommunities(Profile profile) async {
    String url = '${functionUrl}Retrieve/Profile';

    return client.get(
      Uri.parse("$url/${profile.id}"),
    );
  }

  Future<Response> create(CreateCommunityDto community) async {
    String url = '${functionUrl}Create';

    return client.post(
      Uri.parse(url),
      body: jsonEncode(community),
    );
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
