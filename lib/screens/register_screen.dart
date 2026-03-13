// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool  _obscure      = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth  = context.read<AuthProvider>();
    final error = await auth.register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (error != null) {
      AppHelpers.showSnackBar(context, error, isError: true);
    } else {
      AppHelpers.showSnackBar(context, AppStrings.registerSuccess, isSuccess: true);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Join WatchHub', style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.xs),
                const Text('Create your account to start shopping',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.xl),

                TextFormField(
                  controller:         _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText:  'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => AppHelpers.validateRequired(v, 'Full name'),
                ),
                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText:  'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: AppHelpers.validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller:  _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:  'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: AppHelpers.validatePassword,
                ),
                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller:  _confirmCtrl,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText:  'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.dark))
                      : const Text('CREATE ACCOUNT'),
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?',
                        style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
