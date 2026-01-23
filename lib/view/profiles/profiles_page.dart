import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/user/user_cache.dart';
import 'package:wyd_front/view/masks/mask_flow_scope.dart';
import 'package:wyd_front/view/masks/mask_preview.dart';
import 'package:wyd_front/view/profiles/profiles_list.dart';
import 'package:wyd_front/view/settings/settings_page.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaskFlowScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profiles'),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                size: 35.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            SizedBox(width: 10),
          ],
        ),
        body: SingleChildScrollView(
          child: Consumer<UserCache>(
            builder: (context, userProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric( horizontal: 20),
                      child: MaskPreview(),
                    ),
                  ProfilesList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
