import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit your name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 80,
            textCapitalization: TextCapitalization.words,
            validator: Validators.validateName,
            decoration: const InputDecoration(
              labelText: 'Full name',
              hintText: 'Enter your name',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || !context.mounted) return;

    try {
      await context.read<AuthProvider>().updateProfileName(newName);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile name updated.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update your profile: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        children: [
          ProfileHeader(
            name: user?.name ?? 'User',
            email: user?.email ?? '',
            roleLabel: user?.isStaff == true ? 'Authorized staff' : 'Student',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: user == null || isLoading
                ? null
                : () => _editName(context, user.name),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit name'),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                await context.read<AuthProvider>().logout();
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not sign out: $error')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}