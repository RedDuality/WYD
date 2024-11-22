import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/widget/dialog/groups_dialog.dart';

void showEventDialog(BuildContext context, Event event, bool confirmed) {
  var dateText =
      DateFormat('MMMM dd, yyyy').format(event.startTime!).toString();

  var startTimeText = DateFormat('hh:mm a').format(event.startTime!).toString();
  var endTimeText = DateFormat('hh:mm a').format(event.endTime!).toString();

  var timeDetails = '$startTimeText-$endTimeText';

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.title),
          content: SizedBox(
            height: 80,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: <Widget>[
                    Text(''),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(timeDetails,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15)),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  showGroupsDialog(context, event);
                },
                child: const Text('Condividi')),
            confirmed
                ? TextButton(
                    onPressed: () {
                      EventService().decline(event);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Decline'),
                  )
                : TextButton(
                    onPressed: () {
                      EventService().confirm(event);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Confirm'),
                  ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('close'))
          ],
        );
      });
}
