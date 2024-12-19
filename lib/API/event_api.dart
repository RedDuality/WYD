import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/util/interceptors/profile_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

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

  Future<Response> sharedWithHash(String eventHash) async {
    String url = '${functionUrl}SharedWithHash';

    return client.get(Uri.parse('$url/$eventHash'));
  }
  
  Future<Response> update(Event event) async {
    String url = '${functionUrl}Update';

    return client.post(Uri.parse(url), body: jsonEncode(event));
  }

  Future<Response> delete(String eventHash) async {
    String url = '${functionUrl}Delete';

    return client.delete(
      Uri.parse('$url/$eventHash'),
    );
  }

  Future<Response> deleteForAll(String eventHash) async {
    String url = '${functionUrl}DeleteForAll';

    return client.delete(
      Uri.parse('$url/$eventHash'),
    );
  }

  Future<Response> shareToGroups(String eventhash, Set<int> groupIds) async {
    String url = '${functionUrl}Share/Groups';

    return client.post(Uri.parse('$url/$eventhash'),
        body: json.encode(groupIds.toList()));
  }

  Future<Response> confirm(String eventHash) async {
    String url = '${functionUrl}Confirm';

    return client.get(
      Uri.parse('$url/$eventHash'),
    );
  }

  Future<Response> decline(String eventHash) async {
    String url = '${functionUrl}Decline';

    return client.get(
      Uri.parse('$url/$eventHash'),
    );
  }

  Future<Response> addPhoto(String eventHash, BlobData imageData) async {
    String url = '${functionUrl}Photo/Add';

    return client.post(
      Uri.parse('$url/$eventHash'),
      body: jsonEncode(imageData)
    );
  }

}
