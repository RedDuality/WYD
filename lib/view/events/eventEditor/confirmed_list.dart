import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/event/profile_events_provider.dart';
import 'package:wyd_front/view/profiles/profile_tile.dart';

class ConfirmedList extends StatefulWidget {
  final String eventHash;

  const ConfirmedList({required this.eventHash, super.key});

  @override
  State<ConfirmedList> createState() => _ConfirmedListState();
}

class _ConfirmedListState extends State<ConfirmedList> {
  late Future<Set<ProfileEvent>> _profileEventsFuture;

  @override
  void initState() {
    super.initState();
    _profileEventsFuture = ProfileEventsProvider().retrieve(widget.eventHash);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<ProfileEvent>>(
      future: _profileEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nessun profilo trovato.'));
        }

        final confirmed = snapshot.data!.where((pe) => pe.confirmed).toList();
        final toBeConfirmed = snapshot.data!.where((pe) => !pe.confirmed).toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Confermati",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: confirmed.length,
              itemBuilder: (context, index) {
                return ProfileTile(
                  profileHash: confirmed[index].profileHash,
                  type: ProfileTileType.eventMenu,
                );
              },
            ),
            const Text(
              "Da confermare",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: toBeConfirmed.length,
              itemBuilder: (context, index) {
                return ProfileTile(
                  profileHash: toBeConfirmed[index].profileHash,
                  type: ProfileTileType.eventMenu,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
