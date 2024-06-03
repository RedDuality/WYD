import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/controller/auth_interceptor.dart';
import 'package:wyd_front/model/loginDto.dart';


class AuthService{

  String? functionUrl = '${dotenv.env['BACK_URL']}Auth/';


  Client client = InterceptedClient.build(interceptors: [
      AuthInterceptor(),
  ]);


  Future<void> login(LoginDto loginDto) async {
    String url = '${functionUrl}Login';

    await client.post(Uri.parse(url), body: jsonEncode(loginDto));
    //return response;
  }

  Future<String> register(LoginDto loginDto) async {
    String url = '${functionUrl}Register';

    final response = await client.post(Uri.parse(url), body: loginDto);
    if(response.statusCode == 200) {
      return response.body;
    }else {
      throw Exception();
    }
  }

  
}