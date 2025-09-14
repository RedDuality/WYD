import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';
import 'package:wyd_front/view/profiles/profile_tile.dart';

class ConfirmedList extends StatelessWidget {
  final EventViewProvider provider;

  const ConfirmedList({required this.provider, super.key});

  @override
  Widget build(BuildContext context) {
    var sharedWith = ProfileEventsProvider().get(provider.hash!);
    List<ProfileEvent> confirmed = sharedWith.where((pe) => pe.confirmed == true).toList();
    List<ProfileEvent> toBeConfirmed = sharedWith.where((pe) => pe.confirmed == false).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Confermati",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),

        ListView.builder(
          shrinkWrap: true,
          itemCount: confirmed.length,
          itemBuilder: (context, index) {
            return ProfileTile(profileHash: confirmed[index].profileHash, type: ProfileTileType.menu);
          },
        ),
        //const Divider(),
        const Text(
          "Da confermare",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: toBeConfirmed.length,
          itemBuilder: (context, index) {
            return ProfileTile(
              profileHash: toBeConfirmed[index].profileHash,
              type: ProfileTileType.menu,
            );
          },
        ),
      ],
    );
  }
}
