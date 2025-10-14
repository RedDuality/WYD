import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class ProfileInterceptor extends InterceptorContract {
  
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      request.headers['Current-Profile'] =
          UserProvider().getCurrentProfileHash();
    } catch (e) {
      debugPrint("profile interceptor $e");
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
          {required BaseResponse response}) async =>
      response;
}
