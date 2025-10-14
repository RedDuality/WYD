import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/model/profile_service.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';
import 'package:wyd_front/view/profiles/tiles/header_profile_tile.dart';
import 'package:wyd_front/view/profiles/tiles/main_profile_tile.dart';
import 'package:wyd_front/view/profiles/tiles/menu_profile_tile.dart';
import 'package:wyd_front/view/profiles/tiles/view_profile_tile.dart';

enum ProfileTileType { main, view, eventMenu, header }

class ProfileTile extends StatefulWidget {
  final String profileHash;
  final ProfileTileType? type;
  final Widget? trailing;
  final bool fetchDataFromServer;

  const ProfileTile({
    super.key,
    required this.profileHash,
    required this.type,
    this.trailing,
    this.fetchDataFromServer = true,
  });

  @override
  State<ProfileTile> createState() => _ProfileTileState();
}

class _ProfileTileState extends State<ProfileTile> {

  @override
  void initState() {
    super.initState();
    final profile = ProfilesProvider().get(widget.profileHash);
    if (widget.fetchDataFromServer) {
      ProfileService().retrieveOrSynchProfile(profile, widget.profileHash);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listens for changes to a specific profile and rebuilds only when that profile is updated.
    final profile = context.select<ProfilesProvider, Profile?>(
      (provider) => provider.get(widget.profileHash),
    );
    
    switch (widget.type) {
      case ProfileTileType.main:
        return MainProfileTile(profile: profile);
      case ProfileTileType.view:
        return ViewProfileTile(profile: profile, trailing: widget.trailing,);
      case ProfileTileType.eventMenu:
        return MenuProfileTile(profile: profile);
      case ProfileTileType.header:
        return HeaderProfileTile(profile: profile);
      default:
        return ViewProfileTile(profile: profile);
    }
  }
}
