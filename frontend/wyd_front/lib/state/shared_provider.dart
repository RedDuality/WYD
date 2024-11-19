import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';

class SharedProvider extends EventController {
  SharedProvider() {
    super.addAll(_events);
  }
  
  addEvents(List<Event> events) {
    super.addAll(events);
  }
}

DateTime get _now => DateTime.now();

final List<Event> _events = [
  Event(
    date: _now.add(const Duration(days: 1)),
    title: "Project meetings",
    description: "Today is project meeting.",
    startTime: DateTime(
        _now.add(const Duration(days: 1)).year,
        _now.add(const Duration(days: 1)).month,
        _now.add(const Duration(days: 1)).day,
        18),
    endTime: DateTime(
        _now.add(const Duration(days: 1)).year,
        _now.add(const Duration(days: 1)).month,
        _now.add(const Duration(days: 1)).day,
        22),
  )
];
