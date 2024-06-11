
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';

class TestService {
  String? functionUrl = '${dotenv.env['BACK_URL']}';

  Client client = InterceptedClient.build(interceptors: []);

  Future<Response> ping() async {
    String url = '${functionUrl}Ping';

    return client.get(
      Uri.parse(url),
    );
  }
}
