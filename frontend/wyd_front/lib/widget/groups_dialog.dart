// lib/widgets/groups_dialog.dart
import 'package:flutter/material.dart';

class Group {
  final String name;
  bool isSelected;

  Group(this.name, this.isSelected);
}

void showGroupsDialog(BuildContext context, String subjectText) {
  // Lista di esempio di gruppi
  List<Group> groups = [
    Group('Gruppo 1', false),
    Group('Gruppo 2', false),
    Group('Gruppo 3', false),
    Group('Gruppo 4', false),
    Group('Gruppo 5', false),
    Group('Gruppo 6', false),
    Group('Gruppo 7', false),
    Group('Gruppo 8', false),
    Group('Gruppo 9', false),
    Group('Gruppo 10', false),
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Condividi $subjectText con i gruppi'),
            content: SizedBox(
              height: 300,
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: groups.map((group) {
                    return CheckboxListTile(
                      title: Text(group.name),
                      value: group.isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          group.isSelected = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Implementa la logica per la condivisione qui
                  List<String> selectedGroups = groups
                      .where((group) => group.isSelected)
                      .map((group) => group.name)
                      .toList();

                  // Stampa i gruppi selezionati per debug
                  debugPrint('Gruppi selezionati: $selectedGroups');

                  // Mostra il messaggio di conferma
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Evento condiviso con successo!'),
                    ),
                  );
                },
                child: const Text('Condividi'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Chiudi'),
              ),
            ],
          );
        },
      );
    },
  );
}
