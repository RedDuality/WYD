import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/media/media_auto_select_service.dart';

class CalendarViewEventController extends EventController {
  static CalendarViewEventController? _instance;

  factory CalendarViewEventController({bool initialPrivate = true}) {
    _instance ??= CalendarViewEventController._internal(initialPrivate: initialPrivate);
    return _instance!;
  }

  CalendarViewEventController._internal({required bool initialPrivate})
      : confirmedView = initialPrivate,
        super(
          eventFilter: (date, events) => _instance!.myEventFilter(date, events),
        );

  bool confirmedView;

  Event? findEventByHash(String eventHash) {
    return allEvents.whereType<Event>().where((e) => e.eventHash == eventHash).firstOrNull;
  }

  void addEvent(Event event) {
    var originalEvent = findEventByHash(event.eventHash);

    if (originalEvent != null && event.updatedAt.isAfter(originalEvent.updatedAt)) {
      if (originalEvent.endTime != event.endTime) {
        MediaAutoSelectService.addTimer(event);
      }
      super.update(originalEvent, event);
    } else {
      MediaAutoSelectService.addTimer(event);
      super.add(event);
    }
  }

  void changeMode(bool privateMode) {
    confirmedView = privateMode;
    myUpdateFilter();
  }

// triggers a view update
  void myUpdateFilter() {
    super.updateFilter(newFilter: (date, events) => myEventFilter(date, events));
  }

  List<Event> myEventFilter<T extends Object?>(DateTime date, List<CalendarEventData<T>> events) {
    return events
        .whereType<Event>()
        .where((event) =>
            event.occursOnDate(date.toLocal()) &&
            event.currentConfirmed() == confirmedView &&
            (confirmedView || event.endDate.isAfter(DateTime.now())))
        .toList();
  }

  void setHasCachedMedia(String eventHash, bool hasCachedMedia) {
    Event event = CalendarViewEventController().findEventByHash(eventHash)!;
    event.hasCachedMedia = hasCachedMedia;
    addEvent(event);
  }
}
