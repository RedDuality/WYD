import 'package:flutter/material.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/events/eventEditor/event_view.dart';

class AddEventButton extends StatelessWidget {
  final bool confirmed;
  const AddEventButton({super.key, required this.confirmed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        EventViewService.initialize(null, null, confirmed);
        showCustomDialog(context, EventView());
      },
      label: const Text('Aggiungi Evento'),
      icon: const Icon(Icons.add),
    );
  }
}
