import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/authentication_provider.dart';

class AuthInterceptor extends InterceptorContract {
  final BuildContext context;

  AuthInterceptor(this.context);

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    String? token = await authProvider.user?.getIdToken();

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
  Future<BaseResponse> interceptResponse(
          {required BaseResponse response}) async =>
      response;
}
