import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/API/Mask/retrieve_mask_response_dto.dart';

import 'package:http_interceptor/http_interceptor.dart';

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

  Future<RetrieveMaskResponseDto> create(CreateMaskRequestDto createDto) async {
    String url = '${functionUrl}Create';

    var response = await client.post(Uri.parse(url), body: jsonEncode(createDto));

    if (response.statusCode == 200) {
      var dto = RetrieveMaskResponseDto.fromJson(jsonDecode(response.body));
      return dto;
    } else {
      throw "Error while creating the event, please retry later";
    }
  }

}
