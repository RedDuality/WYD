import 'package:flutter/material.dart';
import 'package:wyd_front/state/user/user_cache.dart';
import 'package:wyd_front/view/profiles/tiles/detailed_profile_tile.dart';

class ProfilesList extends StatelessWidget {
  ProfilesList({super.key});

  final List<String> profileHashes = UserCache().getSecondaryProfilesIds().toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Profilo corrente:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        DetailedProfileTile(
          profileId: UserCache().getCurrentProfileId(),
          type: DetailedProfileTileType.main,
        ),
        if (profileHashes.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Altri profili:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        if (profileHashes.isNotEmpty)
          Column(
            children: profileHashes.map((profileHash) {
              return DetailedProfileTile(
                profileId: profileHash,
                type: DetailedProfileTileType.main,
              );
            }).toList(),
          ),
      ],
    );
  }
}
