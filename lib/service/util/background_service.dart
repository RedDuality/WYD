import 'package:workmanager/workmanager.dart';
import 'package:wyd_front/service/util/notification_service.dart';

class BackgroundService {
  static Future<void> executeTask(String task, Map<String, dynamic>? inputData) async {
    switch (task) {
      case "simpleTask1":
        NotificationService.showNotification(task, "prova");
        break;
      default:
        break;
    }
  }

  void testScheduleTask() {
    Workmanager().registerOneOffTask(
      "1",
      "simpleTask1",
      //initialDelay: Duration(minutes: 1),
    );
  }
  
}
