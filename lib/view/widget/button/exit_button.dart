import 'package:flutter/material.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Exit',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close, size: 36),
      color: Colors.grey,
      padding: EdgeInsets.zero,
    );
  }
}
