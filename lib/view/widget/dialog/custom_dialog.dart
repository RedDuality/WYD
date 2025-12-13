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
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth - insetPaddingValue * 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  padding: EdgeInsets.zero,
                  child: child,
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
