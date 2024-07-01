

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/controller/auth_interceptor.dart';
import 'package:wyd_front/controller/request_interceptor.dart';


class UserService {
  String? functionUrl = '${dotenv.env['BACK_URL']}User/';

  Client client = InterceptedClient.build(interceptors: [
    AuthInterceptor(),
    RequestInterceptor(),
  ]);


  Future<Response> retrieve() async {
    String url = '${functionUrl}Retrieve';

    return client.get(
      Uri.parse(url),
    );
  }

  Future<Response> retrievebyId(int userId) async {
    String url = '${functionUrl}Retrieve';

    return client.get(
      Uri.parse('$url/$userId'),
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
