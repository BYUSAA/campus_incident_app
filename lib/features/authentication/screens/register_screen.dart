import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthProvider>().register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (mounted) context.go('/verify-email');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthFormField(
                label: 'Full Name',
                hint: 'Amina Hassan',
                controller: _nameController,
                prefixIcon: Icons.person,
                validator: (val) => Validators.validateRequired(val, 'Name'),
              ),
              const SizedBox(height: 20),
              AuthFormField(
                label: 'ALU Email',
                hint: 'student@alustudent.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),
              AuthFormField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}