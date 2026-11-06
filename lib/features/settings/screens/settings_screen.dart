import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          SwitchListTile(title: Text('Push Notifications'), value: true, onChanged: null),
          SwitchListTile(title: Text('Dark Mode'), value: false, onChanged: null),
          ListTile(title: Text('Privacy Policy')),
          ListTile(title: Text('Terms of Service')),
        ],
      ),
    );
  }
}