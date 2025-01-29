import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/view/profiles/main_profile_tile.dart';
import 'package:wyd_front/view/profiles/profiles_notifier.dart';
import 'package:wyd_front/view/profiles/view_profile_tile.dart';

enum ProfileTileType { main, selection, view }

class ProfileTile extends StatelessWidget {
  final String profileHash;

  final ProfileTileType type;

  const ProfileTile({
    super.key,
    required this.profileHash,
    this.type = ProfileTileType.view,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfilesNotifier>(context);
    var notifier = provider.getNotifier(profileHash);

    return ChangeNotifierProvider.value(
      value: notifier,
      child: Consumer<ProfileNotifier>(
        builder: (context, notifier, child) {
          switch (type) {
            case ProfileTileType.main:
              return MainProfileTile(profile: notifier.profile);
            case ProfileTileType.view:
              return ViewProfileTile(profile: notifier.profile);
            default:
              return ViewProfileTile(profile: notifier.profile);
          }
        },
      ),
    );
  }
}
