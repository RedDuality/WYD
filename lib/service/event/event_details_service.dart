import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';

class EventDetailsService {
  static void addImages(String eventHash, int added) {
    EventDetailsProvider().get(eventHash)!.totalImages += added;
  }

  static void retrieveMedia(String eventHash, {int? start, int? end}) {
    var details = EventDetailsProvider().get(eventHash);

    if (details != null &&
        details.totalImages > 0 &&
        (details.validUntil == null || details.validUntil!.isBefore(DateTime.now()))) {
      var pageSize = 1000;
      var pageNumber = 1;

      var requestPageNumber = details.totalImages > pageSize ? pageNumber : null;
      var requestPageSize = requestPageNumber != null ? pageSize : null;

      MediaService.retrieveEventMediaWithPagination(eventHash,
          pageNumber: requestPageNumber, pageSize: requestPageSize);
    }
  }
}
