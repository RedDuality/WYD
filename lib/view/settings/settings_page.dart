import 'package:flutter/material.dart';
import 'package:wyd_front/API/Test/test_api.dart';
import 'package:wyd_front/view/widget/util/version_detail.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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

class SettingsTile extends StatelessWidget {
  final String title;
  final Widget action;

  const SettingsTile({super.key, required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 350,
        minHeight: 40,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          action,
        ],
      ),
    );
  }
}
