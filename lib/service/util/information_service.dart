import 'package:flutter/material.dart';
import 'package:wyd_front/main.dart';

class InformationService {
  showErrorDialog(BuildContext context, String title, String content) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ]);
        });
  }

  showErrorSnackBar(BuildContext context, String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.red.withOpacity(0.5),
          content: Center(child: Text(title))),
    );
  }

  showInfoSnackBar(BuildContext context, String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          content: Center(child: Text(title))),
    );
  }

  void showOverlaySnackBar(String title) {
    final overlay = navigatorKey.currentState?.overlay;
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(child: Text(title)),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    // Remove the overlay after a duration
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
