import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:wyd_front/API/Media/media_api.dart';
import 'package:wyd_front/API/Media/media_upload_request_dto.dart';
import 'package:wyd_front/API/Media/media_upload_response_dto.dart';
import 'package:wyd_front/model/media/blob_data.dart';
import 'package:wyd_front/model/media/media.dart';

class MediaUploadService {
  Future<Set<Media>> uploadImages(String eventId, List<MediaData> media) async {
    var uploadUrls = await _getUploadUrls(eventId, media);

    var successfulUrls = uploadUrls.where((item) => item.error == null).toList();

    if (successfulUrls.isEmpty) {
      throw "There were some errors during the upload of all the images";
    }

    Set<Media> uploadResults = {};

    for (var blob in media) {
      var mediaUploadUrl = successfulUrls.firstWhere((mediaUploadUrl) => mediaUploadUrl.tempId == blob.tempId);
      var media = await _upload(mediaUploadUrl, blob.mimeType, blob.data);
      if (media != null) {
        uploadResults.add(media);
      }
    }

    if (uploadResults.isEmpty) {
      throw "There were some errors during the upload of the images";
    } else if (uploadResults.length != media.length) {
      debugPrint("Not all the images were successfully uploaded");
    }

    return uploadResults;
  }

  Future<List<MediaUploadResponseDto>> _getUploadUrls(String eventId, List<MediaData> blobs) async {
    var tokenDto = MediaUploadRequestDto(
      parentHash: eventId,
      media: blobs.map((blob) {
        return MediaInfo(
          id: blob.tempId,
          creationDate: blob.creationDate,
          mimetype: blob.mimeType,
        );
      }).toList(),
    );

    return await MediaAPI().getEventUploadUrls(tokenDto);
  }

  Future<Media?> _upload(MediaUploadResponseDto media, String mimeType, Uint8List data) async {
    if (media.url != null) {
      try {
        await MediaAPI().uploadToUrl(data, media.url!, mimeType);
        return Media(eventId: media.id!, name: media.name!, extension: media.extension!, visibility: media.visibility!);
      } catch (e) {
        debugPrint('Upload failed, Error: $e');
      }
    } else {
      debugPrint('Failed: No URL found');
    }
    return null;
  }
}
