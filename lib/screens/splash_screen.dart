// lib/screens/splash_screen.dart
// ─────────────────────────────────────────────
// Animated splash screen — restores user session
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    // Wait for animation + restore session in parallel
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      context.read<AuthProvider>().restoreSession(),
    ]);

    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    Navigator.of(context).pushReplacementNamed(
      auth.isLoggedIn ? '/home' : '/login',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo Icon ──────────────────
                Container(
                  width:  110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    color: AppColors.darkCard,
                  ),
                  child: const Icon(
                    Icons.watch_outlined,
                    size:  56,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── App name ───────────────────
                const Text(
                  'WATCHHUB',
                  style: TextStyle(
                    fontSize:      32,
                    fontWeight:    FontWeight.w900,
                    color:         AppColors.textPrimary,
                    letterSpacing: 8,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                const Text(
                  AppStrings.tagline,
                  style: TextStyle(
                    fontSize:      14,
                    color:         AppColors.primaryLight,
                    letterSpacing: 3,
                    fontWeight:    FontWeight.w400,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                const SizedBox(
                  width:  32,
                  height: 32,
                  child:  CircularProgressIndicator(
                    strokeWidth: 2,
                    color:       AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
