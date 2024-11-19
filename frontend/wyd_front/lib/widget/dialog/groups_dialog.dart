// lib/widgets/groups_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/state/user_provider.dart';

class Group {
  final int id;
  final String name;
  bool isSelected;

  Group(this.id, this.name, this.isSelected);
}

void showGroupsDialog(BuildContext context, Event event) {
  List<Community> communities = context.read<UserProvider>().user!.communities;

  List<Group> groups =
      communities.map((cat) => Group(cat.id, cat.name, false)).toList();

  List<int> selectedIds = [];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Condividi ${event.title} con i gruppi'),
            content: SizedBox(
              height: 300,
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: groups.map((group) {
                    return CheckboxListTile(
                      title: Text(group.name),
                      value: group.isSelected,
                      onChanged: (bool? selected) {
                        setState(() {
                          group.isSelected = selected!;
                          selected
                              ? selectedIds.add(group.id)
                              : selectedIds.remove(group.id);
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

                  List<Community> selectedGroups = communities
                      .where((c) => selectedIds.contains(c.id))
                      .toList();
                  EventService(context: context).share(event, selectedGroups);

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
                onPressed: () async {
                  String? siteUrl = '${dotenv.env['SITE_URL']}';
                  await Clipboard.setData(ClipboardData(
                      text: "$siteUrl#/shared?event=${event.hash}"));

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copiato con successo!'),
                      ),
                    );
                  }
                },
                child: const Text('Copia il link'),
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
