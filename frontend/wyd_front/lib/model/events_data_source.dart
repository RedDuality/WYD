
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wyd_front/model/my_event.dart';

class EventsDataSource extends CalendarDataSource<MyEvent> {
  EventsDataSource() {
    appointments = <MyEvent>[];
    resources = <CalendarResource>[];
  }

  void setAppointements(List<MyEvent> events) {
    appointments = events;
    notifyListeners(CalendarDataSourceAction.add, appointments!);
  }

  void addAppointement(MyEvent event) {
    appointments!.add(event);
    notifyListeners(CalendarDataSourceAction.add, <MyEvent>[event]);
  }

  void removeAppointment(MyEvent event){
    appointments!.remove(event);
    notifyListeners(CalendarDataSourceAction.remove,<MyEvent>[event]);
  }

}
