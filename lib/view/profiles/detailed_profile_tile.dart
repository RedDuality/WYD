import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/detailed_profile.dart';
import 'package:wyd_front/state/profile/detailed_profiles_provider.dart';
import 'package:wyd_front/view/profiles/tiles/header_profile_tile.dart';
import 'package:wyd_front/view/profiles/tiles/main_profile_tile.dart';

enum DetailedProfileTileType { main, header }

class DetailedProfileTile extends StatefulWidget {
  final String profileId;
  final DetailedProfileTileType? type;
  final Widget? trailing;

  const DetailedProfileTile({super.key, required this.profileId, required this.type, this.trailing});

  @override
  State<DetailedProfileTile> createState() => _DetailedProfileTileState();
}

class _DetailedProfileTileState extends State<DetailedProfileTile> {
  @override
  Widget build(BuildContext context) {
    // Listens for changes to a specific profile and rebuilds only when that profile is updated.
    final profile = context.select<DetailedProfileProvider, DetailedProfile?>(
      (provider) => provider.get(widget.profileId),
    );

    switch (widget.type) {
      case DetailedProfileTileType.main:
        return MainProfileTile(profile: profile);
      case DetailedProfileTileType.header:
        return HeaderProfileTile(profile: profile);
      default:
        return Container();
    }
  }
}
