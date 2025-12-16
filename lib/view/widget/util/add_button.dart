import 'package:flutter/material.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';

class AddButton extends StatelessWidget {
  final String text;
  final Widget child;

  const AddButton({
    super.key,
    required this.text,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showCustomDialog(context, child);
      },
      label: Text(text),
      icon: const Icon(Icons.add),
    );
  }
}

