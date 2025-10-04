import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';

class CalendarViewEventController extends EventController {
  bool confirmedView;

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

  Event? findEventByHash(String eventHash) {
    return allEvents.whereType<Event>().where((e) => e.eventHash == eventHash).firstOrNull;
  }

  void changeMode(bool privateMode) {
    confirmedView = privateMode;
    notifyListeners();
    //myUpdateFilter();
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
}
