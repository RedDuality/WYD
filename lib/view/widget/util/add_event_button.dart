import 'package:flutter/material.dart';
import 'package:wyd_front/view/events/eventEditor/event_view.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';

class AddEventButton extends StatelessWidget {

  const AddEventButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showCustomDialog(context, EventView());
      },
      label: const Text('Aggiungi Evento'),
      icon: const Icon(Icons.add),
    );
  }
}
