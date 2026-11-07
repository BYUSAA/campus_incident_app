import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: const Text('Change the appearance of the app on this device.'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: theme.toggle,
          ),
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Privacy and access'),
            subtitle: Text('Your reports are protected by Firebase security rules.'),
          ),
        ],
      ),
    );
  }
}
