import 'package:wyd_front/model/event_details.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';

class EventDetailsService {
  static EventDetails getOrCreate(String eventHash) =>
      EventDetailsProvider().get(eventHash) ?? _createDetails(eventHash);

  static EventDetails _createDetails(String eventHash) {
    var details = EventDetails(hash: "created", totalImages: 0);
    EventDetailsProvider().create(eventHash, details);
    return details;
  }


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
