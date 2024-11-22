import 'package:flutter/material.dart';
import 'package:wyd_front/widget/dialog/inspect_event_dialog.dart';

class AddEventButton extends StatelessWidget {
  const AddEventButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showInspectEventDialog(context, null, null, null);
      },
      label: const Text('Aggiungi Evento'),
      icon: const Icon(Icons.add),
    );
  }
}
