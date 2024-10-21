import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/controller/auth_interceptor.dart';
import 'package:wyd_front/controller/request_interceptor.dart';
import 'package:wyd_front/model/login_dto.dart';


class AuthService{

  String? functionUrl = '${dotenv.env['BACK_URL']}Auth/';


  Client client = InterceptedClient.build(interceptors: [
      AuthInterceptor(),
      RequestInterceptor(),
  ]);


  Future<Response> login(LoginDto loginDto) async {
    String url = '${functionUrl}Login';

    return client.post(Uri.parse(url), body: jsonEncode(loginDto));
  }

  Future<Response> register(LoginDto loginDto) async {
    String url = '${functionUrl}Register';

    return client.post(Uri.parse(url), body: loginDto);
  }

  Future<Response> testToken() async {
    String url = '${functionUrl}TestToken';

    return client.get(Uri.parse(url));
  }

  Future<Response> verifyLoginToken(credential) async {
    String url = '${functionUrl}verifyLoginToken';

    debugPrint("credential $credential");
    return Response("ciao", 200);//client.get(Uri.parse(url));
  }


}