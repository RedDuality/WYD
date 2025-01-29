import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/model/DTO/retrieve_user_dto.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class AuthAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}Auth/';

  final InterceptedClient client;

  AuthAPI()
      : client = InterceptedClient.build(interceptors: [
          RequestInterceptor(),
          AuthInterceptor(),
        ]);

  Future<RetrieveUserDto> verifyToken(String token) async {
    final url = '${functionUrl}VerifyToken';
    try {
      var response =
          await client.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return RetrieveUserDto.fromJson(jsonDecode(response.body));
      } else {
        throw "Server verification failed: ${response.statusCode}";
      }
    } on TimeoutException catch (_) {
      throw "Server is probably waking up, please wait a moment and retry";
    }
  }
}


