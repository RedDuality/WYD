import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/util/config/config_service.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class TestAPI {
  String? functionUrl = '${ConfigService().backUrl}/wyd/api/Test/';

  Client client = InterceptedClient.build(interceptors: [
    RequestInterceptor(),
  ]);

  Future<Response> ping() async {
    final String url = '${functionUrl}Ping';

    return client.get(
      Uri.parse(url),
    );
  }

  Future<Response> testNotifications() async {
    final String url = '${functionUrl}Notifications';

    Client authClient = InterceptedClient.build(interceptors: [
      AuthInterceptor(),
      RequestInterceptor(),
    ]);

    return authClient.get(
      Uri.parse(url),
    );
  }
}
