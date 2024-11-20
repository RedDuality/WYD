import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';

class SharedProvider extends EventController {

  SharedProvider() : super();
  
  addEvents(List<Event> events) {
    super.addAll(events);
  }
  
  addEvent(Event event){
    super.add(event);
    notifyListeners();
  }
}


