import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';
import 'package:wyd_front/view/profiles/profile_tile.dart';
import 'package:wyd_front/view/settings/settings_page.dart';

class ProfilesPage extends StatelessWidget {
  ProfilesPage({super.key});

  final List<String> profileHashes = UserProvider().getSecondaryProfilesHashes().toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Ciao!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: ImageProviderService.getImage(size: ImageSize.big),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    AuthenticationProvider().signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Log out'),
                ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Profilo corrente:',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ProfileTile(
                      profileHash: UserProvider().getCurrentProfileHash(),
                      type: ProfileTileType.main,
                    ),
                    if (profileHashes.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Altri profili:',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (profileHashes.isNotEmpty)
                      Column(
                        children: profileHashes.map((profileHash) {
                          return ProfileTile(
                            profileHash: profileHash,
                            type: ProfileTileType.main,
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
