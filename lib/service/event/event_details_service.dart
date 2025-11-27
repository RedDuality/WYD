import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';

class EventDetailsService {
  static void addImages(String eventId, int added) {
    EventDetailsStorage().get(eventId)!.totalImages += added;
  }

  static void retrieveMediaFromServer(String eventId, {int? start, int? end}) {
    var details = EventDetailsStorage().get(eventId);

    if (details != null &&
        details.totalImages > 0 &&
        (details.validUntil == null || details.validUntil!.isBefore(DateTime.now()))) {
      var pageSize = 1000;
      var pageNumber = 1;

      var requestPageNumber = details.totalImages > pageSize ? pageNumber : null;
      var requestPageSize = requestPageNumber != null ? pageSize : null;

      MediaService.retrieveEventMediaWithPagination(eventId,
          pageNumber: requestPageNumber, pageSize: requestPageSize);
    }
  }
}
