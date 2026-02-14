
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';

class RequestInterceptor extends InterceptorContract {

   @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {

    try {
      //request.headers[HttpHeaders.accessControlAllowOriginHeader] = '*';
      request.headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=UTF-8';
    } catch (e) {
      debugPrint("request interceptor $e");
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async => response;
}