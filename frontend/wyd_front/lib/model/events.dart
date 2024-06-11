
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wyd_front/model/my_event.dart';

class Events extends CalendarDataSource {
  Events() {
    appointments = <MyEvent>[];
    resources = <CalendarResource>[];
  }

  void setAppointements(List<MyEvent> events) {
    appointments = events;
    notifyListeners(CalendarDataSourceAction.add, appointments!);
  }

  void addAppointement(MyEvent event) {
    appointments!.add(event);
    notifyListeners(CalendarDataSourceAction.add, appointments!);
  }
}
