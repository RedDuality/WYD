import 'package:wyd_front/API/Media/media_api.dart';
import 'package:wyd_front/API/Media/media_read_request_dto.dart';
import 'package:wyd_front/model/media/blob_data.dart';
import 'package:wyd_front/model/enum/media_type.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/model/media/media.dart';
import 'package:wyd_front/service/media/media_upload_service.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';

class MediaService {
  // from BlobProvider, either cached or selected by user
  static Future<void> uploadImages(String eventId, List<MediaData> blobs) async {
    var media = await MediaUploadService().uploadImages(eventId, blobs);
    EventDetailsStorage().addTotalMedia(eventId, media.length);
  }

  // from Notifications
  static Future<void> retrieveImageUpdatesByHash(Event event) async {
    var details = EventDetailsStorage().get(event.id);

    if (details != null) {
      EventDetailsStorage().invalidateMediaCache(event.id);
    }
  }

  static Future<void> retrieveEventMediaWithPagination(String eventId, {int? pageNumber, int? pageSize}) async {
    var readDto = MediaReadRequestDto(parentHash: eventId, pageNumber: pageNumber, pageSize: pageSize);

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

      EventDetailsStorage().addMedia(eventId, media, validUntil: validUntil);
    }
  }
}
