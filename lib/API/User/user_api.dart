import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';
import 'package:wyd_front/API/User/store_fcm_token_request_dto.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class UserAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}/wyd/api/User/';

  final InterceptedClient client;

  UserAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
        ]);

  Future<RetrieveUserResponseDto> register() async {
    final url = '${functionUrl}Register';
    try {
      var response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return RetrieveUserResponseDto.fromJson(jsonDecode(response.body));
      } else {
        throw "Server verification failed: ${response.statusCode}";
      }
    } on TimeoutException catch (_) {
      throw "Server is probably waking up, please wait a moment and retry";
    }
  }

  Future<RetrieveUserResponseDto> login() async {
    final url = '${functionUrl}Login';
    try {
      var response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return RetrieveUserResponseDto.fromJson(jsonDecode(response.body));
      } else {
        throw "Server verification failed: ${response.statusCode}";
      }
    } on TimeoutException catch (_) {
      throw "Server is probably waking up, please wait a moment and retry";
    }
  }

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

    var response = await client.post(Uri.parse(url), body: token);

    if (response.statusCode == 200) {
      return;
    } else {
      throw "Server verification failed: ${response.statusCode}";
    }
  }

/*

  Future<Response> update(User user) async {
    String url = '${functionUrl}Update';

    return client.post(Uri.parse(url), body: jsonEncode(user));
  }

  Future<Response> delete(int userId) async {
    String url = '${functionUr}Delete';

    return client.delete(
      Uri.parse('$url/$userId'),
    );
  }

*/

  Future<Response> retrieveCommunities() async {
    String url = '${functionUrl}Communities';

    return client.get(
      Uri.parse(url),
    );
  }
}
