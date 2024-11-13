import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/controller/auth_interceptor.dart';
import 'package:wyd_front/controller/request_interceptor.dart';
import 'package:wyd_front/model/my_event.dart';
import 'package:wyd_front/model/test_event.dart';

class EventService {
  String? functionUrl = '${dotenv.env['BACK_URL']}Event/';

  final InterceptedClient client;
  
  EventService()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
        ]);

  Future<Response> create(TestEvent event) async {
    String url = '${functionUrl}Create';

    return client.post(Uri.parse(url), body: jsonEncode(event));
  }

  Future<Response> retrieveFromHash(String eventHash) async {
    String url = '${functionUrl}Retrieve';

    return client.get(Uri.parse('$url/$eventHash'));
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

  Future<Response> share(int eventId, Set<int> userIds) async {
    String url = '${functionUrl}Share/Community';

    return client.post(Uri.parse('$url/$eventId'),
        body: json.encode(userIds.toList()));
  }

  Future<Response> confirm(MyEvent event) async {
    String url = '${functionUrl}Confirm';
    int? eventId = event.id as int?;

    return client.get(
      Uri.parse('$url/$eventId'),
    );
  }

  Future<Response> confirmFromHash(String eventHash, bool confirmed) async {
    String url = '${functionUrl}Confirm/Hash';

    return client.post(Uri.parse('$url/$eventHash'), body: confirmed.toString());
  }

  Future<Response> decline(MyEvent event) async {
    String url = '${functionUrl}Decline';
    int? eventId = event.id as int?;

    return client.get(
      Uri.parse('$url/$eventId'),
    );
  }
}
