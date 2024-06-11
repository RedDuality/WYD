import 'package:flutter/material.dart';

class ShowGroupsDialogButton extends StatelessWidget {
  const ShowGroupsDialogButton({super.key});

  void showGroupsDialog(BuildContext context) {
    List<String> groups = ['Gruppo 1', 'Gruppo 2', 'Gruppo 3', 'Gruppo 4'];
    Map<String, bool> selectedGroups = {for (var group in groups) group: false};

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleziona gruppi'),
              content: SizedBox(
                height: 200,
                child: ListView(
                  children: groups.map((group) {
                    return CheckboxListTile(
                      title: Text(group),
                      value: selectedGroups[group],
                      onChanged: (bool? value) {
                        setState(() {
                          selectedGroups[group] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    List<String> selected = selectedGroups.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();
                    // Esegui l'azione desiderata con i gruppi selezionati
                    debugPrint('Gruppi selezionati: $selected');
                    Navigator.of(context).pop();
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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
