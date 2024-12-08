import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/auth_interceptor.dart';

class UserAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}User/';

  final InterceptedClient client;

  UserAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
        ]);

  Future<Response> retrieve() async {
    String url = '${functionUrl}Retrieve';

    return client.get(
      Uri.parse(url),
    );
  }

  Future<Response> retrieveById(int userId) async {
    String url = '${functionUrl}Retrieve';

    return client.get(
      Uri.parse('$url/$userId'),
    );
  }

  Future<Response> searchByTag(String searchTag) async {
    String url = '${functionUrl}SearchbyTag';

    return client.get(
      Uri.parse('$url/$searchTag'),
    );
  }

/*

  Future<Response> update(User user) async {
    String url = '${functionUrl}Update';

    return client.post(Uri.parse(url), body: jsonEncode(user));
  }

  Future<Response> delete(int userId) async {
    String url = '${functionUr}Delete';

    return client.delete(
      Uri.parse('$url/$userId'),
    );
  }

*/

  Future<Response> listEvents() async {
    String url = '${functionUrl}Events';

    return client.get(
      Uri.parse(url),
    );
  }

  Future<Response> retrieveCommunities() async {
    String url = '${functionUrl}Communities';

    return client.get(
      Uri.parse(url),
    );
  }
}
