import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/image_size.dart';
import 'package:wyd_front/model/users/account.dart';
import 'package:wyd_front/model/users/detailed_profile.dart';
import 'package:wyd_front/service/media/logo_service.dart';
import 'package:wyd_front/service/user/account_service.dart';
import 'package:wyd_front/service/util/import/import_service.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class MainTileOptions extends StatefulWidget {
  final DetailedProfile profile;

  const MainTileOptions({super.key, required this.profile});

  @override
  State<MainTileOptions> createState() => _MainTileOptionsState();
}

class _MainTileOptionsState extends State<MainTileOptions> {
  late Future<Set<Account>> _accountsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future once to prevent multiple calls on rebuild
    _accountsFuture = AccountService.getAccountsThatCanImport();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentProfile = widget.profile.id == UserCache().getCurrentProfileId();

    if (!isCurrentProfile) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 'switch') {
            // Add your switch profile logic here
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'switch',
            child: Row(
              children: [
                Icon(Icons.swap_horiz, size: 20),
                SizedBox(width: 10),
                Text("Switch to this profile"),
              ],
            ),
          ),
        ],
      );
    }

    return FutureBuilder<Set<Account>>(
      future: _accountsFuture,
      builder: (context, snapshot) {
        List<PopupMenuEntry<String>> menuItems = [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          menuItems.add(
            const PopupMenuItem(
              enabled: false,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          menuItems.add(
            const PopupMenuItem(
              enabled: false,
              child: Text("Error loading accounts"),
            ),
          );
        } else if (snapshot.hasData) {
          final accounts = snapshot.data!;

          if (accounts.isEmpty) {
            menuItems.add(
              const PopupMenuItem(
                enabled: false,
                child: Text("No accounts available", style: TextStyle(color: Colors.grey)),
              ),
            );
          } else {
            for (var account in accounts) {
              menuItems.add(
                PopupMenuItem<String>(
                  value: 'import_${account.email}',
                  child: Row(
                    children: [
                      Image(
                        image: LogoService.importProviderLogo(account.platform, ImageSize.mini),
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 10),
                      Text("Import from ${account.email}"),
                    ],
                  ),
                ),
              );
            }
          }
        }

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value.startsWith('import_')) {
              final email = value.replaceFirst('import_', '');
              var account = snapshot.data!.firstWhere((a) => a.email == email);
              ImportService.importFromGoogleCalendar(account);
            }
          },
          itemBuilder: (context) => menuItems,
        );
      },
    );
  }
}
