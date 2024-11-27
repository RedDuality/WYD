import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';

class SharedProvider extends EventController {
  // Private static instance
  static final SharedProvider _instance = SharedProvider._internal();

  // Factory constructor returns the singleton instance
  factory SharedProvider() {
    return _instance;
  }

  // Private named constructor
  SharedProvider._internal() : super();

  addEvents(List<Event> events) {
    super.addAll(events);
  }

  addEvent(Event event) {
    super.add(event);
    notifyListeners();
  }
}
