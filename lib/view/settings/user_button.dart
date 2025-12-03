import 'package:flutter/material.dart';
import 'package:wyd_front/service/user/user_service.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(
        Icons.person,
        size: 35.0,
      ),
      onSelected: (value) {
        switch (value) {
          case 0:
            // Handle "Current user"
            debugPrint("Current user tapped");
            break;
          case 1:
            // Handle "Accounts"
            debugPrint("Accounts tapped");
            break;
          case 2:
            UserService.logOut();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<int>(
          value: 0,
          child: ListTile(
            leading: Icon(Icons.account_circle),
            title: Text("Current user"),
          ),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.switch_account),
            title: Text("Accounts"),
          ),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
          ),
        ),
      ],
    );
  }
}
