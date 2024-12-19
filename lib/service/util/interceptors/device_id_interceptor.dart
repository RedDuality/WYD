import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/util/real_time_service.dart';

class DeviceIdInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      request.headers['deviceId'] = RealTimeService().deviceId;
    } catch (e) {
      debugPrint("deveiceId interceptor $e");
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
          {required BaseResponse response}) async =>
      response;
}
