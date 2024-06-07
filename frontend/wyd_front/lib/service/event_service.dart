import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/controller/auth_interceptor.dart';
import 'package:wyd_front/model/my_event.dart';

class EventService {
  String? functionUrl = '${dotenv.env['BACK_URL']}Event/';

  Client client = InterceptedClient.build(interceptors: [
    AuthInterceptor(),
  ]);

  Future<Response> create(MyEvent event) async {
    String url = '${functionUrl}Create';

    return client.post(Uri.parse(url), body: jsonEncode(event));
  }

  Future<Response> update(MyEvent event) async {
    String url = '${functionUrl}Update';

    return client.post(Uri.parse(url), body: jsonEncode(event));
  }

  Future<Response> delete(MyEvent event) async {
    String url = '${functionUrl}Delete';
    int? eventId = event.id as int?;

    return client.delete(
      Uri.parse('$url/$eventId'),
    );
  }

  Future<Response> deleteForAll(MyEvent event) async {
    String url = '${functionUrl}DeleteForAll';
    int? eventId = event.id as int?;

    return client.delete(
      Uri.parse('$url/$eventId'),
    );
  }

  Future<Response> share(MyEvent event, List<int> userIds) async {
    String url = '${functionUrl}Share';
    int? eventId = event.id as int?;

    return client.post(
      Uri.parse('$url/$eventId'), 
      body: jsonEncode(userIds)
    );
  }

  Future<Response> confirm(MyEvent event) async {
    String url = '${functionUrl}Confirm';
    int? eventId = event.id as int?;

    return client.get(
      Uri.parse('$url/$eventId'),
    );
  }

  Future<Response> decline(MyEvent event) async {
    String url = '${functionUrl}Decline';
    int? eventId = event.id as int?;

    return client.get(
      Uri.parse('$url/$eventId'),
    );
  }
}
