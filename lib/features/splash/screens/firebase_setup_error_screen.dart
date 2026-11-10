import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirebaseSetupErrorApp extends StatelessWidget {
  const FirebaseSetupErrorApp({
    super.key,
    required this.error,
  });

  final Object error;

  static const _applicationId = 'com.byusa.campus_incident_reporter';
  static const _setupCommand = r'.\tooling\bootstrap-firebase.ps1';

  bool get _missingProjectOptions => error is UnsupportedError;

  Future<void> _copySetupCommand(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _setupCommand));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Firebase setup command copied.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMissingOptions = _missingProjectOptions;

    return MaterialApp(
      title: 'Campus Incident Reporter setup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EFF),
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      isMissingOptions
                          ? Icons.cloud_off_outlined
                          : Icons.cloud_sync_outlined,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isMissingOptions
                          ? 'Connect your Firebase project'
                          : 'Firebase could not start',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isMissingOptions
                          ? 'This repository does not yet contain the generated Android configuration '
                              'for the INZIRA Firebase project. The project ID is already '
                              'set in the repository; complete the authenticated FlutterFire '
                              'registration steps below to generate the Android options.'
                          : 'Firebase initialization failed before the app could open. '
                              'Check the diagnostic details below, then confirm that the '
                              'Android app is registered in the selected Firebase project.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const _SetupStep(
                      number: '1',
                      title: 'Create or select your Firebase project',
                      description:
                          'Use the existing INZIRA project (Project ID: inzira-498621). '
                          'Enable Email/Password Authentication and create Cloud Firestore. '
                          'Cloud Storage photo uploads require the Blaze pay-as-you-go plan '
                          'and a billing account; you can skip Storage while using Spark.',
                    ),
                    const SizedBox(height: 14),
                    const _SetupStep(
                      number: '2',
                      title: 'Register the Android app',
                      description: 'Use this exact Android application ID:',
                    ),
                    const SizedBox(height: 8),
                    const _SelectableValue(value: _applicationId),
                    const SizedBox(height: 14),
                    const _SetupStep(
                      number: '3',
                      title: 'Generate the project configuration',
                      description:
                          'Run this command from the repository root in Windows PowerShell. '
                          'The script already targets INZIRA (inzira-498621).',
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: SelectableText(
                          _setupCommand,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => _copySetupCommand(context),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy PowerShell command'),
                    ),
                    const SizedBox(height: 20),
                    const _SetupStep(
                      number: '4',
                      title: 'Restart the app',
                      description:
                          'When FlutterFire finishes successfully, stop the current '
                          'app run, execute flutter pub get, and start it again with '
                          'flutter run -d YOUR_DEVICE_ID.',
                    ),
                    const SizedBox(height: 20),
                    Divider(color: colorScheme.outlineVariant),
                    Text(
                      'Diagnostic: ${error.runtimeType}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (!isMissingOptions) ...[
                      const SizedBox(height: 8),
                      SelectableText(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 15, child: Text(number)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectableValue extends StatelessWidget {
  const _SelectableValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
