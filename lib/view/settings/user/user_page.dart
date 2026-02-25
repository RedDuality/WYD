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
              const Text(
                "Accounts",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 40),
              AccountList(),
              const SizedBox(width: 40),
              Tooltip(
                message: 'Log out',
                child: ElevatedButton.icon(
                  onPressed: () => UserService.logOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(155,
                        55), /*
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,*/
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
