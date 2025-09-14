
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class TestAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}';

  Client client = InterceptedClient.build(interceptors: [RequestInterceptor(),]);

  Future<Response> ping() async {
    String url = '${functionUrl}Ping';

    return client.get(
      Uri.parse(url),
    );
  }
}
