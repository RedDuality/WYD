import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/API/Mask/retrieve_mask_response_dto.dart';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/API/Mask/retrieve_profile_masks_request_dto.dart';
import 'package:wyd_front/API/Mask/retrieve_user_masks_request_dto.dart';
import 'package:wyd_front/API/Mask/retrieve_view_mask_response_dto.dart';
import 'package:wyd_front/API/Mask/update_mask_request_dto.dart';

import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/profile_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class MaskAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}/wyd/api/Mask/';

  final InterceptedClient client;

  MaskAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
          ProfileInterceptor(),
        ]);

  Future<List<RetrieveMaskResponseDto>> retrieveUserMasks(RetrieveUserMasksRequestDto retrieveUserMasksDto) async {
    String url = '${functionUrl}RetrieveUserMasks';

    var response = await client.post(Uri.parse(url), body: jsonEncode(retrieveUserMasksDto));

    if (response.statusCode == 200) {
      var dtos = List<RetrieveMaskResponseDto>.from(
          json.decode(response.body).map((dto) => RetrieveMaskResponseDto.fromJson(dto)));

      return dtos;
    }

    throw "There was an error while fetching masks";
  }

  Future<List<RetrieveViewMaskResponseDto>> retrieveProfileMasks(RetrieveProfileMasksRequestDto retrieveProfileMasksDto) async {
    String url = '${functionUrl}RetrieveProfileMasks';

    var response = await client.post(Uri.parse(url), body: jsonEncode(retrieveProfileMasksDto));
    if (response.statusCode == 200) {
      var dtos = List<RetrieveViewMaskResponseDto>.from(
          json.decode(response.body).map((dto) => RetrieveViewMaskResponseDto.fromJson(dto)));

      return dtos;
    }

    throw "There was an error while fetching masks";
  }

  Future<RetrieveMaskResponseDto> create(CreateMaskRequestDto createDto) async {
    String url = '${functionUrl}Create';

    var response = await client.post(Uri.parse(url), body: jsonEncode(createDto));

    if (response.statusCode == 200) {
      var dto = RetrieveMaskResponseDto.fromJson(jsonDecode(response.body));
      return dto;
    } else {
      throw "Error while creating the mask, please retry later";
    }
  }

  Future<RetrieveMaskResponseDto> update(UpdateMaskRequestDto updateDto) async {
    String url = '${functionUrl}Update';

    var response = await client.post(Uri.parse(url), body: jsonEncode(updateDto));

    if (response.statusCode == 200) {
      var dto = RetrieveMaskResponseDto.fromJson(jsonDecode(response.body));
      return dto;
    } else {
      throw "Error while updating the mask, please retry later";
    }
  }

  Future<RetrieveMaskResponseDto> retrieveSingleMask(String maskId) async {
    String url = '${functionUrl}retrieveMask';

    var response = await client.get(Uri.parse('$url/$maskId'));

    if (response.statusCode == 200) {
      var dto = RetrieveMaskResponseDto.fromJson(jsonDecode(response.body));
      return dto;
    } else {
      throw "Error while retrieving the mask";
    }
  }

  Future<RetrieveMaskResponseDto> retrieveEventMask(String eventId) async {
    String url = '${functionUrl}retrieveEventMask';

    var response = await client.get(Uri.parse('$url/$eventId'));

    if (response.statusCode == 200) {
      var dto = RetrieveMaskResponseDto.fromJson(jsonDecode(response.body));
      return dto;
    } else {
      throw "Error while retrieving the event's mask";
    }
  }
}
