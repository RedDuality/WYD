import 'package:flutter/material.dart';
import 'package:wyd_front/state/user/user_provider.dart';
import 'package:wyd_front/view/profiles/profile_tile.dart';
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
          child: ProfileTile(
            profileHash: UserProvider().getCurrentProfileHash(),
            type: ProfileTileType.header
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
