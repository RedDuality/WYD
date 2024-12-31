import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wyd_front/service/util/notification_service.dart';

class BackgroundService {
  static Future<void> executeTask(
      String task, Map<String, dynamic>? inputData) async {
    debugPrint("CALLEDBACK $task");

    switch (task) {
      case "simpleTask1":
        NotificationService.showNotification(task, "prova");
        break;
      case "simpleTask2":
        debugPrint("CALLEDBACK1 $task");
        NotificationService.showNotification(task, "prova");
        break;
      default:
        NotificationService.showNotification(task, "prova");
        break;
    }
  }

  void scheduleTask() {
    debugPrint("SCHEDULE");
    Workmanager().registerOneOffTask(
      "1",
      "simpleTask1",
      //initialDelay: Duration(minutes: 1),
    );
  }

  void scheduleTask2() {
    debugPrint("SCHEDULE2");
    Workmanager().registerOneOffTask(
      "2",
      "simpleTask2",
      initialDelay: Duration(seconds: 30),
    );
  }
}
