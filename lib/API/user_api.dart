import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class UserAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}User/';

  final InterceptedClient client;

  UserAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
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

  Future<List<Event>> listEvents() async {
    String url = '${functionUrl}Events';

    var response = await client.get(
      Uri.parse(url),
    );
    
    if (response.statusCode == 200) {
      List<Event> events = List<Event>.from(
          json.decode(response.body).map((evento) => Event.fromJson(evento)));

      return events;
    }

    throw "There was an error while fetching events";
  }

  Future<Response> retrieveCommunities() async {
    String url = '${functionUrl}Communities';

    return client.get(
      Uri.parse(url),
    );
  }
}
