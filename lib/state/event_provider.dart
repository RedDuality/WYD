import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';

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

  updateEvent(Event event) {
    var originalEvent = findEventByHash(event.hash);

    originalEvent != null ? update(originalEvent, event) : add(event);
  }

  changeMode(bool privateMode) {
    private = privateMode;
    myUpdateFilter();
  }

  myUpdateFilter() {
    super
        .updateFilter(newFilter: (date, events) => myEventFilter(date, events));
  }

  List<Event> myEventFilter<T extends Object?>(
      DateTime date, List<CalendarEventData<T>> events) {
    return events
        .whereType<Event>()
        .where(
            (event) => event.occursOnDate(date) && event.confirmed() == private)
        .toList();
  }
}
