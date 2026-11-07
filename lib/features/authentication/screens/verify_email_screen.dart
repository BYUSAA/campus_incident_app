import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _sending = false;

  Future<void> _signOut() async {\n    try {\n      await context.read<AuthProvider>().logout();\n      if (mounted) context.go('/login');\n    } catch (error) {\n      if (!mounted) return;\n      ScaffoldMessenger.of(context).showSnackBar(\n        SnackBar(content: Text('Could not sign out: $error')),\n      );\n    }\n  }\n\n  Future<void> _checkVerification() async {
    setState(() => _checking = true);
    try {
      final verified = await context.read<AuthProvider>().refreshVerification();
      if (!mounted) return;
      if (verified) {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your email is not verified yet. Open the link in your inbox, then try again.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not check verification: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await context.read<AuthProvider>().resendVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new verification email has been sent.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not resend the email: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().firebaseUser?.email ?? 'your ALU email';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 80, color: AppConstants.primaryColor),
              const SizedBox(height: 24),
              const Text('Verify your email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to $email. Open the email and follow the link before continuing.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppConstants.greyText),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checking ? null : _checkVerification,
                  child: _checking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('I have verified my email'),
                ),
              ),
              TextButton(
                onPressed: _sending ? null : _resend,
                child: Text(_sending ? 'Sending…' : 'Resend verification email'),
              ),
              TextButton(
                onPressed: _signOut,
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
