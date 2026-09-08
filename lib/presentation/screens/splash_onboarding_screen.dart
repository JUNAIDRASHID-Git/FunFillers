import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'main_layout_screen.dart';

class SplashOnboardingScreen extends StatefulWidget {
  const SplashOnboardingScreen({super.key});

  @override
  State<SplashOnboardingScreen> createState() => _SplashOnboardingScreenState();
}

class _SplashOnboardingScreenState extends State<SplashOnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: MaxWidthContainer(
          maxWidth: 480,
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Image in Glassmorphic / Shadowed Container
                    Container(
                      width: 130,
                      height: 130,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                      ),
                      child: Image.asset(
                        'assets/images/fun_fillers_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.smart_toy_rounded,
                          size: 72,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App Title
                    const Text(
                      'FunFillers',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // App Tagline
                    const Text(
                      'Little Toys • Big Smiles',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Subtle Progress Indicator
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
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
