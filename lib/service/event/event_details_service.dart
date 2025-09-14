import 'package:wyd_front/model/event_details.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';

class EventDetailsService {
  static EventDetails getOrCreate(String eventHash) =>
      EventDetailsProvider().get(eventHash) ?? _createDetails(eventHash);

  static EventDetails _createDetails(String eventHash) {
    var details = EventDetails(hash: "created", totalImages: 0);
    EventDetailsProvider().set(eventHash, details);
    return details;
  }

  static void updateFromFetched(String eventHash, EventDetails details) {
    details.lastFetchedTime = DateTime.now();
    update(eventHash, details);
  }

  static void update(String eventHash, EventDetails details) {
    EventDetailsProvider().set(eventHash, details);
  }

  static void addImages(String eventHash, int added) {
    EventDetailsProvider().get(eventHash)!.totalImages += added;
  }

  static void retrieveMedia(String eventHash, {int? start, int? end}) {
    var details = EventDetailsProvider().get(eventHash);
    if (details != null && details.totalImages > 0) {
      var pageSize = 1000;
      var pageNumber = 1;

      var requestPageNumber = details.totalImages > pageSize ? pageNumber : null;
      var requestPageSize = requestPageNumber != null ? pageSize : null;

      MediaService.retrieveEventMediaWithPagination(eventHash, pageNumber: requestPageNumber, pageSize: requestPageSize);
    }
  }
}
