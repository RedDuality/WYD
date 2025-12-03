import 'package:flutter/material.dart';
import 'package:wyd_front/state/user/user_cache.dart';
import 'package:wyd_front/view/profiles/tiles/detailed_profile_tile.dart';
import 'package:wyd_front/view/profiles/profiles_page.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const Header({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: actions != null && actions!.isNotEmpty
          ? Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: actions!,
                ),
              ),
            )
          : null,
      title: Text(title),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilesPage()),
            );
          },
          child: DetailedProfileTile(
            profileId: UserCache().getCurrentProfileId(),
            type: DetailedProfileTileType.header
          ),
        ),
      ],
      centerTitle: true,
      //backgroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
