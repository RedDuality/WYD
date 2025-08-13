import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/util/photo_retriever_service.dart';

class EventProvider extends EventController {
  // Private static instance
  static EventProvider? _instance;

  // Factory constructor returns the singleton instance
  factory EventProvider({bool initialPrivate = true}) {
    _instance ??= EventProvider._internal(initialPrivate: initialPrivate);
    return _instance!;
  }

  // Private named constructor
  EventProvider._internal({required bool initialPrivate})
      : private = initialPrivate,
        super(
          eventFilter: (date, events) => _instance!.myEventFilter(date, events),
        );

  bool private;

  Event? findEventByHash(String eventHash) {
    return allEvents
        .whereType<Event>()
        .where((e) => e.hash == eventHash)
        .firstOrNull;
  }

  Event retrieveEventByHash(String eventHash) {
    var event = findEventByHash(eventHash);
    if (event != null) {
      return event;
    }
    throw "There was an error while retrieving the event";
  }

  void updateEvent(Event updatedEvent) {
    var originalEvent = retrieveEventByHash(updatedEvent.hash);

    if (originalEvent.endTime != updatedEvent.endTime) {
      PhotoRetrieverService().addTimer(updatedEvent);
    }
    update(originalEvent, updatedEvent);
  }

  void addEvent(Event event) {
    PhotoRetrieverService().addTimer(event);
    super.add(event);
  }

  void changeMode(bool privateMode) {
    private = privateMode;
    myUpdateFilter();
  }

  void myUpdateFilter() {
    super
        .updateFilter(newFilter: (date, events) => myEventFilter(date, events));
  }

  List<Event> myEventFilter<T extends Object?>(
      DateTime date, List<CalendarEventData<T>> events) {
    return events
        .whereType<Event>()
        .where((event) =>
            event.occursOnDate(date.toLocal()) && event.confirmed() == private)
        .toList();
  }


}
