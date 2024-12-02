import 'package:flutter/material.dart';
import 'package:wyd_front/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/widget/event/event_detail.dart';

class AddEventButton extends StatelessWidget {
  final bool confirmed;
  const AddEventButton({super.key, required this.confirmed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showCustomDialog(context,
            EventDetail(initialEvent: null, date: null, confirmed: confirmed));
      },
      label: const Text('Aggiungi Evento'),
      icon: const Icon(Icons.add),
    );
  }
}
