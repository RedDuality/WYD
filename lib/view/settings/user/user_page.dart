import 'package:flutter/material.dart';
import 'package:wyd_front/service/user/user_service.dart';
import 'package:wyd_front/view/settings/user/account_list.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Accounts"),
              AccountList(),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => UserService.logOut(),
                icon: const Icon(Icons.logout),
                tooltip: 'Log out',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
