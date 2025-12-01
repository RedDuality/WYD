import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http show put;
import 'package:wyd_front/model/enum/media_type.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/API/Media/media_read_request_dto.dart';
import 'package:wyd_front/API/Media/media_read_response_dto.dart';
import 'package:wyd_front/API/Media/media_upload_request_dto.dart';
import 'package:wyd_front/API/Media/media_upload_response_dto.dart';

import 'package:wyd_front/service/util/interceptors/auth_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/profile_interceptor.dart';
import 'package:wyd_front/service/util/interceptors/request_interceptor.dart';

class MediaAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}/wyd/api/Media/';

  final InterceptedClient client;

  MediaAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
          RequestInterceptor(),
          ProfileInterceptor(),
        ]);

  Future<void> uploadToUrl(Uint8List data, String url, String mimeType) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': mimeType,
        },
        body: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload to S3: ${response.statusCode}');
      }

      debugPrint('Upload successful');
    } catch (e) {
      debugPrint('An error occurred during upload: $e');
      rethrow;
    }
  }

  Future<List<MediaUploadResponseDto>> getEventUploadUrls(MediaUploadRequestDto dto) async {
    String url = '${functionUrl}event/getUploadUrls';

    var response = await client.post(Uri.parse(url), body: jsonEncode(dto));
    if (response.statusCode == 200) {
      List<MediaUploadResponseDto> results = List<MediaUploadResponseDto>.from(
          json.decode(response.body).map((evento) => MediaUploadResponseDto.fromJson(evento)));
      return results;
    }
    throw "Error while retrieving the upload urls";
  }

  Future<List<MediaReadResponseDto>> getReadUrls(MyMediaType type, MediaReadRequestDto dto) async {
    String url = '$functionUrl${type.name}/getReadUrls';

    var response = await client.post(Uri.parse(url), body: jsonEncode(dto));
    if (response.statusCode == 200) {
      List<MediaReadResponseDto> results = List<MediaReadResponseDto>.from(
          json.decode(response.body).map((evento) => MediaReadResponseDto.fromJson(evento)));
      return results;
    }
    throw "Error while retrieving the read urls";
  }
}
