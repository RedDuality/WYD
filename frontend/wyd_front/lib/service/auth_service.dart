import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/controller/auth_interceptor.dart';
import 'package:wyd_front/controller/request_interceptor.dart';
class AuthService {
  String? functionUrl = '${dotenv.env['BACK_URL']}Auth/';

  final InterceptedClient client;

  AuthService(BuildContext context)
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(context),
          RequestInterceptor(),
        ]);

  Future<Response> verifyToken(String token) async {
    final url = '${functionUrl}VerifyToken';
    return client.post(Uri.parse(url), body: jsonEncode({"token": token}));
  }

  Future<Response> verifyTokenAndCreate(String token) async {
    final url = '${functionUrl}VerifyTokenAndCreate';
    return client.post(Uri.parse(url), body: jsonEncode({"token": token}));
  }
}
