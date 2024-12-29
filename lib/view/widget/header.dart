import 'package:flutter/material.dart';
import 'package:wyd_front/view/profiles_page.dart';

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
                  children: actions!, // Display all actions in the Row on the left
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
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/logoimage_mini.png'),
              radius: 20,
            ),
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
