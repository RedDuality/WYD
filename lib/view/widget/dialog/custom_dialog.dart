import 'package:flutter/material.dart';

void showCustomDialog(BuildContext context, Widget child) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double insetPaddingValue;

          // Set the padding value based on screen width
          if (screenWidth > 1000) {
            insetPaddingValue = 100;
          } else if (screenWidth > 700) {
            insetPaddingValue = 50;
          } else {
            insetPaddingValue = 15;
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(insetPaddingValue),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    padding: EdgeInsets.zero,
                    child: child,
                  ),
                ),
                /*
                  Positioned(
                      top: -100,
                      child: Image.network("https://i.imgur.com/2yaf2wb.png",
                          width: 150, height: 150))
                */
              ],
            ),
          );
        },
      );
    },
  );
}
