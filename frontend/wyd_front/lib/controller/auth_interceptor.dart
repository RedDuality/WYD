
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends InterceptorContract {

   @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';

    //debugPrint("interceptor: $token");
    
    try {
      request.headers[HttpHeaders.accessControlAllowOriginHeader] = '*';
      request.headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    } catch (e) {
      debugPrint(e.toString());
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async => response;
}