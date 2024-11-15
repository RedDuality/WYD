import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';




class PrivateProvider extends EventController {

  PrivateProvider() : super();
  
  addEvents(List<Event> events){
    super.addAll(events);
    notifyListeners();
  }

  addEvent(Event event){
    super.add(event);
    notifyListeners();
  }
  
}