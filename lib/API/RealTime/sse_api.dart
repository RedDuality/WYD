import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/util/config/config_service.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';

class SseAPI {
  String functionUrl = '${ConfigService().backUrl}/wyd/api/Communication/';

  static final InterceptedClient _client = InterceptedClient.build(interceptors: [
    AuthInterceptor(),
  ]);

  InterceptedClient get client => _client;

  Uri getStreamUri() {
    return Uri.parse('${functionUrl}CreateSseChannel');
  }
}
