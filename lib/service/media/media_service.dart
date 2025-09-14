import 'package:wyd_front/API/Media/media_api.dart';
import 'package:wyd_front/API/Media/media_read_request_dto.dart';
import 'package:wyd_front/model/blob_data.dart';
import 'package:wyd_front/model/enum/media_type.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/media.dart';
import 'package:wyd_front/service/media/media_upload_service.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';

class MediaService {
  // from BlobProvider, either cached or selected by user
  static Future<void> uploadImages(String eventHash, List<MediaData> blobs) async {
    var media = await MediaUploadService().uploadImages(eventHash, blobs);
    EventDetailsProvider().addTotalMedia(eventHash, media.length);
  }

  // from Notifications
  static Future<void> retrieveImageUpdatesByHash(Event event) async {
    var details = EventDetailsProvider().get(event.eventHash);

    if (details != null) {
      EventDetailsProvider().invalidateMediaCache(event.eventHash);
    }
  }

  static Future<void> retrieveEventMediaWithPagination(String eventHash, {int? pageNumber, int? pageSize}) async {
    var readDto = MediaReadRequestDto(parentHash: eventHash, pageNumber: pageNumber, pageSize: pageSize);

    var dtos = await MediaAPI().getReadUrls(MediaType.events, readDto);
    if (dtos.isNotEmpty) {
      var media = dtos.map((m) => Media.fromDto(m)).toSet();

      DateTime? validUntil;
      if (pageNumber == null || pageNumber == 1) {
        var any = media.firstWhere(
          (m) => m.error == null,
          orElse: () => throw "Error while retrieving the media",
        );
        validUntil = any.validUntil;
      }

      EventDetailsProvider().addMedia(eventHash, media, validUntil: validUntil);
    }
  }

  Media getWydLogo() {
    return Media(
      hash: "",
    );
  }
}
