import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';

Future<void> showSharedDialog(BuildContext context, String eventHash) async {
  debugPrint(eventHash);
  final event = await EventService().retrieveFromHash(eventHash);

  if (event != null && context.mounted) {
    var dateText =
        DateFormat('MMMM dd, yyyy').format(event.startTime!).toString();
    var startTimeText =
        DateFormat('hh:mm a').format(event.startTime!).toString();
    var endTimeText = DateFormat('hh:mm a').format(event.endTime!).toString();
    var timeDetails = '$startTimeText - $endTimeText';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.title),
          content: SizedBox(
            height: 100, // Altezza modificata per prevenire errori di rendering
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dateText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  timeDetails,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (!PrivateProvider().allEvents.contains(event)) {
                  PrivateProvider().addEvent(event);
                }
                Navigator.of(context).pop();
              },
              child: const Text('I\'ll be there!'),
            ),
            TextButton(
              onPressed: () {
                context.read<SharedProvider>().addEvent(event);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }
}
