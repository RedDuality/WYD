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
          ProfileInterceptor(),
        ]);

  Future<Event> retrieveFromHash(String eventHash) async {
    String url = '${functionUrl}Retrieve';

    var response = await client.get(Uri.parse('$url/$eventHash'));

    if (response.statusCode == 200) {
      var event = Event.fromJson(jsonDecode(response.body));
      return event;
    }

    throw "Error while fetching the event";
  }

  //automatically add the event
  Future<Event> sharedWithHash(String eventHash) async {
    String url = '${functionUrl}Shared';

    var response = await client.get(Uri.parse('$url/$eventHash'));
    if (response.statusCode == 200) {
      var event = Event.fromJson(jsonDecode(response.body));

      return event;
    }

    throw "Error while retrieving event";
  }

  Future<Event> create(Event event) async {
    String url = '${functionUrl}Create';

    var response = await client.post(Uri.parse(url), body: jsonEncode(event));

    if (response.statusCode == 200) {
      Event event = Event.fromJson(jsonDecode(response.body));
      return event;
    } else {
      throw "Error while creating the event, please retry later";
    }
  }

  Future<Event> update(Event event) async {
    String url = '${functionUrl}Update';

    var response = await client.post(Uri.parse(url), body: jsonEncode(event));
    if (response.statusCode == 200) {
      //TODO check decode is really needed
      Event event = Event.fromJson(jsonDecode(response.body));
      return event;
    }
    throw "Error while updating the event";
  }

  Future<Event> uploadImages(String eventHash, List<BlobData> blobs) async {
    String url = '${functionUrl}Upload/Photos';

    var response = await client.post(Uri.parse('$url/$eventHash'),
        body: jsonEncode(blobs));
    if (response.statusCode == 200) {
      Event event = Event.fromJson(jsonDecode(response.body));
      return event;
    }
    throw "Error while updating the event";
  }

  Future<void> confirm(String eventHash) async {
    String url = '${functionUrl}Confirm';

    var response = await client.get(
      Uri.parse('$url/$eventHash'),
    );
    if (response.statusCode == 200) {
      return;
    }
    throw "It was not possible to confirm the event";
  }

  Future<void> decline(String eventHash) async {
    String url = '${functionUrl}Decline';

    var response = await client.get(
      Uri.parse('$url/$eventHash'),
    );
    if (response.statusCode == 200) {
      return;
    }
    throw "It was not possible to decline the event";
  }

  Future<void> shareToGroups(String eventhash, Set<int> groupIds) async {
    String url = '${functionUrl}Share/Groups';

    var response = await client.post(Uri.parse('$url/$eventhash'),
        body: json.encode(groupIds.toList()));
    if (response.statusCode == 200) {
      return;
    }
    throw "There was an error while sharing the event";
  }

  Future<void> delete(String eventHash) async {
    String url = '${functionUrl}Delete';

    var response = await client.delete(
      Uri.parse('$url/$eventHash'),
    );

    if (response.statusCode == 200) {
      return;
    }
    throw "Error while deleting the event";
  }

  Future<void> deleteForAll(String eventHash) async {
    String url = '${functionUrl}DeleteForAll';

    var response = await client.delete(
      Uri.parse('$url/$eventHash'),
    );
    if (response.statusCode == 200) {
      return;
    }
    throw "Error while deleting the event";
  }
}
