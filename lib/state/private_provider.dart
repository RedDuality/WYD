import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/model/event.dart';




class PrivateProvider extends EventController {

  // Private static instance
  static final PrivateProvider _instance = PrivateProvider._internal();

  // Factory constructor returns the singleton instance
  factory PrivateProvider() {
    return _instance;
  }

  // Private named constructor
  PrivateProvider._internal() : super();
  
  addEvents(List<Event> events){
    super.addAll(events);
    notifyListeners();
  }

  addEvent(Event event){
    super.add(event);
    notifyListeners();
  }
  
}