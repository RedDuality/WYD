import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';

class ProfilesPage extends StatelessWidget {
  final List<Profile> profiles = [
    Profile(id: 1, name: "Giovanni", tag: "Developer"),
    Profile(id: 2, name: "Maria", tag: "Designer"),
    Profile(id: 3, name: "Luca", tag: "Manager"),
  ];

  ProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Ciao Giovanni',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            getImage(),
            Expanded(
              child: ListView.builder(
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(profiles[index].name),
                    subtitle: Text(profiles[index].tag),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getImage() {
    // Replace this with your actual image fetching logic
    return Image.asset(
      'assets/images/logoimage.png',
      width: 300,
      height: 300,
    );
  }
}
