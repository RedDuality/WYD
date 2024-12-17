import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:wyd_front/service/util/interceptor/auth_interceptor.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/util/interceptor/profile_interceptor.dart';
import 'package:wyd_front/service/util/interceptor/request_interceptor.dart';

class EventAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}Event/';

  final InterceptedClient client;
  
  EventAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
          ProfileInterceptor()
          
        ]);


  Future<Response> create(Event event) async {
    String url = '${functionUrl}Create';

    return client.post(Uri.parse(url), body: jsonEncode(event));
  }

  Future<Response> retrieveFromHash(String eventHash) async {
    String url = '${functionUrl}Retrieve';

    return client.get(Uri.parse('$url/$eventHash'));
  }

  Future<Response> update(Event event) async {
    String url = '${functionUrl}Update';

    return client.post(Uri.parse(url), body: jsonEncode(event));
  }

  Future<Response> delete(Event event) async {
    String url = '${functionUrl}Delete';
    int? eventId = event.id as int?;

    return client.delete(
      Uri.parse('$url/$eventId'),
    );
  }

  Future<Response> deleteForAll(Event event) async {
    String url = '${functionUrl}DeleteForAll';
    int? eventId = event.id as int?;

    return client.delete(
      Uri.parse('$url/$eventId'),
    );
  }

  Future<Response> shareToGroups(int eventId, Set<int> groupIds) async {
    String url = '${functionUrl}Share/Groups';

    return client.post(Uri.parse('$url/$eventId'),
        body: json.encode(groupIds.toList()));
  }

  Future<Response> confirm(Event event) async {
    String url = '${functionUrl}Confirm';
    int? eventId = event.id as int?;

    return client.get(
      Uri.parse('$url/$eventId'),
    );
  }

  Future<Response> decline(Event event) async {
    String url = '${functionUrl}Decline';
    int? eventId = event.id as int?;

    return client.get(
      Uri.parse('$url/$eventId'),
    );
  }

  Future<Response> addPhoto(int eventId, BlobData imageData) async {
    String url = '${functionUrl}Photo/Add';

    return client.post(
      Uri.parse('$url/$eventId'),
      body: jsonEncode(imageData)
    );
  }

}
