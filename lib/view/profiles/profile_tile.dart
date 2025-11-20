import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';
import 'package:wyd_front/view/profiles/tiles/menu_profile_tile.dart';
import 'package:wyd_front/view/profiles/tiles/view_profile_tile.dart';

enum ProfileTileType { view, eventMenu }

class ProfileTile extends StatefulWidget {
  final String profileId;
  final ProfileTileType? type;
  final Widget? trailing;

  const ProfileTile({super.key, required this.profileId, required this.type, this.trailing});

  @override
  State<ProfileTile> createState() => _ProfileTileState();
}

class _ProfileTileState extends State<ProfileTile> {
  @override
  Widget build(BuildContext context) {
    // Listens for changes to a specific profile and rebuilds only when that profile is updated.
    final profile = context.select<ProfileProvider, Profile?>(
      (provider) => provider.get(widget.profileId),
    );

    switch (widget.type) {
      case ProfileTileType.view:
        return ViewProfileTile(
          profile: profile,
          trailing: widget.trailing,
        );
      case ProfileTileType.eventMenu:
        return MenuProfileTile(profile: profile);
      default:
        return Container();
    }
  }
}
