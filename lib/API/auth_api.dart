import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/util/request_interceptor.dart';
class AuthAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}Auth/';

  final InterceptedClient client;

  AuthAPI()
      : client = InterceptedClient.build(interceptors: [
          RequestInterceptor(),
        ]);

  Future<Response> verifyToken(String token) async {
    final url = '${functionUrl}VerifyToken';
    return client.post(Uri.parse(url), body: jsonEncode({"token": token}));
  }
}
