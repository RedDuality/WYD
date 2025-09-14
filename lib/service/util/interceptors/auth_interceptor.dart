import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';

class AuthInterceptor extends InterceptorContract {
  
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final authProvider = AuthenticationProvider();
    String? token = await authProvider.user?.getIdToken();
    try {
      request.headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    } catch (e) {
      debugPrint("auth interceptor $e");
    }
    return request;
  }

  Future<String?> getAuthHeader() async {
    final authProvider = AuthenticationProvider();
    String? token = await authProvider.user?.getIdToken();
    return "Bearer $token";
  }

  @override
  Future<BaseResponse> interceptResponse(
          {required BaseResponse response}) async =>
      response;
}
