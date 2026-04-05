import 'package:flutter/material.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      // Adding a small margin around the button itself
      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
      child: Material(
        // Makes it semi-transparent so it doesn't grab too much attention
        color: Colors.black.withAlpha(130),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: 'Exit',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, size: 36),
          color: Colors.grey,
          constraints: const BoxConstraints(),
          padding: EdgeInsets.all(2),
        ),
      ),
    );
  }
/*
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Exit',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close, size: 36),
      color: Colors.grey,
      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
    );
  }*/
}
