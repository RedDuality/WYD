import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/API/Community/share_event_request_dto.dart';
import 'package:wyd_front/API/Event/create_event_request_dto.dart';
import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_multiple_events_request_dto.dart';
import 'package:wyd_front/API/Event/update_event_request_dto.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/profile_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class EventAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}/wyd/api/Event/';

  final InterceptedClient client;

  EventAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
          ProfileInterceptor(),
        ]);

  Future<List<RetrieveEventResponseDto>> listEvents(RetrieveMultipleEventsRequestDto retrieveEventsDto) async {
    String url = '${functionUrl}ListByProfile';

    var response = await client.post(Uri.parse(url), body: jsonEncode(retrieveEventsDto));

    if (response.statusCode == 200) {
      var dtos = List<RetrieveEventResponseDto>.from(
          json.decode(response.body).map((dto) => RetrieveEventResponseDto.fromJson(dto)));

      return dtos;
    }

    throw "There was an error while fetching events";
  }

  Future<List<RetrieveEventResponseDto>> retrieveUpdatedAfter(RetrieveMultipleEventsRequestDto retrieveEventsDto) async {
    String url = '${functionUrl}UpdateByProfile';

    var response = await client.post(Uri.parse(url), body: jsonEncode(retrieveEventsDto));

    if (response.statusCode == 200) {
      var dtos = List<RetrieveEventResponseDto>.from(
          json.decode(response.body).map((dto) => RetrieveEventResponseDto.fromJson(dto)));

      return dtos;
    }

    throw "There was an error while fetching updated events";
  }

  Future<RetrieveEventResponseDto> retrieveEssentialsFromHash(String eventHash) async {
    String url = '${functionUrl}RetrieveEssentials';

    var response = await client.get(Uri.parse('$url/$eventHash'));

    if (response.statusCode == 200) {
      var dto = RetrieveEventResponseDto.fromJson(jsonDecode(response.body));
      return dto;
    }

    throw "Error while fetching the event";
  }



  Future<RetrieveEventResponseDto> retrieveDetailsFromHash(String eventHash) async {
    String url = '${functionUrl}RetrieveDetails';

    var response = await client.get(Uri.parse('$url/$eventHash'));

    if (response.statusCode == 200) {
      var dto = RetrieveEventResponseDto.fromJson(jsonDecode(response.body));
      return dto;
    }

    throw "Error while fetching the event with its details";
  }

  //automatically add the event
  Future<RetrieveEventResponseDto> sharedWithHash(String eventHash) async {
    String url = '${functionUrl}RetrieveFromShared';

    var response = await client.get(Uri.parse('$url/$eventHash'));
    if (response.statusCode == 200) {
      var event = RetrieveEventResponseDto.fromJson(jsonDecode(response.body));

      return event;
    }

    throw "Error while retrieving event";
  }

  Future<Set<ProfileEvent>> retriveProfileEvents(String eventHash) async {
    String url = '${functionUrl}GetProfileEvents';

    var response = await client.get(Uri.parse('$url/$eventHash'));
    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body) as List<dynamic>;
      var pes = decoded.map((pe) => ProfileEvent.fromJson(pe as Map<String, dynamic>)).toSet();

      return pes.cast<ProfileEvent>();
    }

    throw "Error while retrieving the profiles of the event";
  }

  Future<RetrieveEventResponseDto> create(CreateEventRequestDto createDto) async {
    String url = '${functionUrl}Create';

    var response = await client.post(Uri.parse(url), body: jsonEncode(createDto));

    if (response.statusCode == 200) {
      var dto = RetrieveEventResponseDto.fromJson(jsonDecode(response.body));
      return dto;
    } else {
      throw "Error while creating the event, please retry later";
    }
  }

  Future<RetrieveEventResponseDto> update(UpdateEventRequestDto updateDto) async {
    String url = '${functionUrl}Update';

    var response = await client.post(Uri.parse(url), body: jsonEncode(updateDto));
    if (response.statusCode == 200) {
      RetrieveEventResponseDto event = RetrieveEventResponseDto.fromJson(jsonDecode(response.body));
      return event;
    }
    throw "Error while updating the event";
  }

  Future confirm(String eventHash) async {
    String url = '${functionUrl}Confirm';

    var response = await client.get(
      Uri.parse('$url/$eventHash'),
    );
    if (response.statusCode == 200) {
      return;
    }
    throw "It was not possible to confirm the event";
  }

  Future decline(String eventHash) async {
    String url = '${functionUrl}Decline';

    var response = await client.get(
      Uri.parse('$url/$eventHash'),
    );
    if (response.statusCode == 200) {
      return;
    }
    throw "It was not possible to decline the event";
  }

/*
  Future<List<Media>> retrieveImageUpdatesFromHash(String eventHash) async {
    String url = '${functionUrl}Retrieve';

    var response = await client.get(Uri.parse('$url/$eventHash'));

    if (response.statusCode == 200) {
      var event = RetrieveEventResponseDto.fromJson(jsonDecode(response.body));
      return event.media;
    }

    throw "Error while fetching the event";
  }
*/

  Future<RetrieveEventResponseDto> shareToProfiles(String eventhash, Set<ShareEventRequestDto> dtos) async {
    String url = '${functionUrl}Share';

    var response = await client.post(Uri.parse('$url/$eventhash'), body: json.encode(dtos.toList()));
    if (response.statusCode == 200) {
      RetrieveEventResponseDto event = RetrieveEventResponseDto.fromJson(jsonDecode(response.body));
      return event;
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
