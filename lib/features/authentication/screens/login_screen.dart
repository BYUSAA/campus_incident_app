import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AuthProvider>().login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppConstants.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.school, size: 60, color: AppConstants.primaryColor),
                const SizedBox(height: 24),
                const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Log in to report campus incidents.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),
                
                AuthFormField(
                  label: 'Email',
                  hint: 'student@alustudent.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),
                AuthFormField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}