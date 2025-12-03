import 'package:flutter/material.dart';
import 'package:wyd_front/API/Test/test_api.dart';
import 'package:wyd_front/view/settings/settings_tile.dart';
import 'package:wyd_front/view/settings/user_button.dart';
import 'package:wyd_front/view/widget/util/version_detail.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          UserButton(),
          SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SettingsTile(
              title: "Language",
              action: ElevatedButton(onPressed: () => {}, child: Text("Italiano")),
            ),
            SettingsTile(
              title: "Dark mode",
              action: ElevatedButton(onPressed: () => {}, child: Text("Light")),
            ),
            SettingsTile(
              title: "Locale",
              action: ElevatedButton(onPressed: () => {}, child: Text("+1:00 CET")),
            ),
            SettingsTile(
              title: "Scansione automatica della galleria",
              action: ElevatedButton(onPressed: () => {}, child: Text("Attiva")),
            ),
            SettingsTile(
              title: "Check for images of all past events",
              action: ElevatedButton(onPressed: () => {}, child: Text("From last month")),
            ),
            SettingsTile(
              title: "Align profile preferences on all devices",
              action: ElevatedButton(onPressed: () => {}, child: Text("For all profiles")),
            ),
            SettingsTile(
              title: "Test",
              action: ElevatedButton(onPressed: () => {TestAPI().testNotifications()}, child: Text("Test")),
            ),
            VersionDetail(),
          ],
        ),
      ),
    );
  }
}
