import 'package:flutter/material.dart';
import 'package:wyd_front/model/users/account.dart';
import 'package:wyd_front/state/user/account_storage.dart';
import 'package:wyd_front/view/settings/user/account_tile.dart';

class AccountList extends StatelessWidget {
  const AccountList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<Account>>(
      future: AccountStorage().getAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading accounts: ${snapshot.error}'));
        }

        final accounts = snapshot.data;
        if (accounts == null || accounts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No accounts found."),
          );
        }

        return Column(
          children: accounts.map((account) {
            return AccountTile(account: account);
          }).toList(),
        );
      },
    );
  }
}
