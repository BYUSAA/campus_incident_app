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

  Future<void> _signOut() async {
    try {
      await context.read<AuthProvider>().logout();
      if (mounted) context.go('/login');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not sign out: $error')),
      );
    }
  }

  Future<void> _checkVerification() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final verified =
          await context.read<AuthProvider>().refreshVerification();
      if (!mounted) return;
      if (verified) {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your email is not verified yet. Open the link in your inbox, then try again.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not check verification: $error')),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await context.read<AuthProvider>().resendVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new verification email has been sent.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not resend the email: $error')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        context.watch<AuthProvider>().firebaseUser?.email ?? 'your ALU email';

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verify your email',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We sent a verification link to $email. Open the email and follow the link before continuing.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppConstants.greyText),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _checking ? null : _checkVerification,
                      child: _checking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('I have verified my email'),
                    ),
                  ),
                  TextButton(
                    onPressed: _sending ? null : _resend,
                    child: Text(
                      _sending ? 'Sending…' : 'Resend verification email',
                    ),
                  ),
                  TextButton(
                    onPressed: _signOut,
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}