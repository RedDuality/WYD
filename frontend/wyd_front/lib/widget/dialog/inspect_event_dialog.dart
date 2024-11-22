import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/widget/event_detail.dart';

void showInspectEventDialog(
    BuildContext context, Event? event, DateTime? date, bool? confirmed) {

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {

        return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(100),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).colorScheme.onPrimary),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: const EventDetail(),
                ),

                /*
                  Positioned(
                      top: -100,
                      child: Image.network("https://i.imgur.com/2yaf2wb.png",
                          width: 150, height: 150))
                */
              ],
            ));
      });
}
