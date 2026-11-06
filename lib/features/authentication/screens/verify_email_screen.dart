import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read, size: 80, color: AppConstants.primaryColor),
              const SizedBox(height: 24),
              const Text('Verify your Email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'We have sent a verification link to your ALU email. Please verify to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppConstants.greyText),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.read<AuthProvider>().logout(), // Logs out to trigger login redirect
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}