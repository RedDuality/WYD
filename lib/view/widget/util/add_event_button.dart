import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/event_detail_provider.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/event/event_detail.dart';

class AddEventButton extends StatelessWidget {
  final bool confirmed;
  const AddEventButton({super.key, required this.confirmed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        EventDetailProvider provider =
            Provider.of<EventDetailProvider>(context, listen: false);
        provider.initialize(null, null, confirmed);
        showCustomDialog(context, EventDetail());
      },
      label: const Text('Aggiungi Evento'),
      icon: const Icon(Icons.add),
    );
  }
}
