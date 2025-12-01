import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';

class SseApi {
  String functionUrl = '${dotenv.env['BACK_URL']}/wyd/api/Communication/';

  static final InterceptedClient _client = InterceptedClient.build(interceptors: [
    AuthInterceptor(),
  ]);

  InterceptedClient get client => _client;

  Uri getStreamUri() {
    return Uri.parse('${functionUrl}CreateSseChannel');
  }
}
