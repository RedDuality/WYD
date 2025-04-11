import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/model/profile_service.dart';
import 'package:wyd_front/state/profiles_provider.dart';
import 'package:wyd_front/view/profiles/tiles/header_profile_tile.dart';
import 'package:wyd_front/view/profiles/tiles/main_profile_tile.dart';
import 'package:wyd_front/view/profiles/tiles/menu_profile_tile.dart';
import 'package:wyd_front/view/profiles/tiles/view_profile_tile.dart';

enum ProfileTileType { main, view, menu, header }

class ProfileTile extends StatelessWidget {
  final String profileHash;
  final ProfileTileType? type;
  final bool fetchDataFromServer;

  const ProfileTile({
    super.key,
    required this.profileHash,
    required this.type,
    this.fetchDataFromServer = true,
  });

  @override
  Widget build(BuildContext context) {
    final profile = context.select<ProfilesProvider, Profile?>(
      (provider) => provider.get(profileHash),
    );
    if (fetchDataFromServer) {
      ProfileService().synchProfile(profile, profileHash);
    }
    switch (type) {
      case ProfileTileType.main:
        return MainProfileTile(profile: profile);
      case ProfileTileType.view:
        return ViewProfileTile(profile: profile);
      case ProfileTileType.menu:
        return MenuProfileTile(profile: profile);
      case ProfileTileType.header:
        return HeaderProfileTile(profile: profile);
      default:
        return ViewProfileTile(profile: profile);
    }
  }
}
