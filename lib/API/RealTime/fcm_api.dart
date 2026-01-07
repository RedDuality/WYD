import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:wyd_front/API/User/store_fcm_token_request_dto.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class FcmAPI {
  String functionUrl = '${dotenv.env['BACK_URL']}/wyd/api/Communication/';

  static final InterceptedClient _client = InterceptedClient.build(interceptors: [
    AuthInterceptor(),
    RequestInterceptor(),
  ]);

  InterceptedClient get client => _client;

  Future<void> storeFCMToken(StoreFcmTokenRequestDto dto) async {
    final url = '${functionUrl}StoreFcmToken';

    var response = await client.post(Uri.parse(url), body: jsonEncode(dto));

    if (response.statusCode == 200) {
      return;
    } else {
      throw "Server verification failed: ${response.statusCode}";
    }
  }

  Future<void> deleteFCMToken(String token) async {
    final url = '${functionUrl}RemoveFcmToken';

    var response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(token),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw "Server verification failed: ${response.statusCode}";
    }
  }

}