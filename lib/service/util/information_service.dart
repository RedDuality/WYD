import 'package:flutter/material.dart';

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

  void showInfoPopup(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 60.0,
            child: Material(
              color: Colors.transparent,
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
