import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/authentication_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class ProfilesPage extends StatefulWidget {
  ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  final List<Profile> profiles = UserProvider().user!.profiles;
  String _version = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthenticationProvider();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
      ),
      body: Center(
        child: Column(
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
              child: ImageService().getImage(size: ImageSize.big),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await authProvider.signOut(); // Chiama la funzione signOut
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Sfondo bianco
                foregroundColor: Colors.black, // Testo nero
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Log out'),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'I tuoi Profili:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircleAvatar(
                              backgroundImage:
                                  ImageService().getImageProvider(),
                              radius: 30,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profiles[index].name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(profiles[index].tag),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add the version number text box here
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                _version,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
