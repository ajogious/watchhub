// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool  _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth  = context.read<AuthProvider>();
    final error = await auth.login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    if (error != null) {
      AppHelpers.showSnackBar(context, error, isError: true);
    } else {
      AppHelpers.showSnackBar(context, AppStrings.loginSuccess, isSuccess: true);
      // Load cart & wishlist after login
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                // ── Logo ─────────────────────
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    color: AppColors.darkCard,
                  ),
                  child: const Icon(Icons.watch_outlined,
                      size: 40, color: AppColors.primaryLight),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('WATCHHUB', style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary, letterSpacing: 6,
                )),
                const Text(AppStrings.tagline, style: TextStyle(
                  fontSize: 12, color: AppColors.primaryLight, letterSpacing: 2,
                )),
                const SizedBox(height: AppSpacing.xxl),

                // ── Form ──────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Welcome back', style: AppTextStyles.heading2),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Sign in to your account', style: AppTextStyles.bodyMedium),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller:   _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText:  'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: AppHelpers.validateEmail,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      TextFormField(
                        controller:  _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText:   'Password',
                          prefixIcon:  const Icon(Icons.lock_outline),
                          suffixIcon:  IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: AppHelpers.validatePassword,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/forgot-password'),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.dark))
                            : const Text('SIGN IN'),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?",
                              style: AppTextStyles.bodyMedium),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),

                      // ── Demo hint ──────────────
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Column(
                          children: [
                            Text('Demo Credentials', style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                            SizedBox(height: AppSpacing.xs),
                            Text('admin@watchhub.com / admin123',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
