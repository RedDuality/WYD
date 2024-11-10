import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/controller/auth_interceptor.dart';
import 'package:wyd_front/controller/request_interceptor.dart';

class CommunityService {
  String? functionUrl = '${dotenv.env['BACK_URL']}Comminity/';

  final InterceptedClient client;
  
  CommunityService()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
        ]);

  Future<Response> create(String name, List<int> userIds) async {
    String url = '${functionUrl}Create';

    return client.post(
      Uri.parse('$url/$name'),
      body: jsonEncode(userIds),
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
