import 'package:syncfusion_flutter_calendar/calendar.dart';

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> events, List<CalendarResource> resources) {
    appointments = events;
    resources = resources;
  }
}
