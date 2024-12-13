import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/util/interceptor/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptor/request_interceptor.dart';

class UserAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}Profile/';

  final InterceptedClient client;

  UserAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
        ]);

  Future<Response> searchByTag(String searchTag) async {
    String url = '${functionUrl}SearchbyTag';

    return client.get(
      Uri.parse('$url/$searchTag'),
    );
  }
}
