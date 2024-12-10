import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/state/authentication_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class AuthInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final authProvider = AuthenticationProvider();
    String? token = await authProvider.user?.getIdToken();

    //debugPrint("interceptor: $token");

    try {
      request.headers[HttpHeaders.accessControlAllowOriginHeader] = '*';
      request.headers[HttpHeaders.authorizationHeader] = "Bearer $token";
      request.headers['Current-Profile'] =
          UserProvider().getCurrentProfileHash();
    } catch (e) {
      debugPrint(e.toString());
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
          {required BaseResponse response}) async =>
      response;
}
