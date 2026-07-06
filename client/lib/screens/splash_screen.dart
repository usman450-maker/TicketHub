import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/routes/route_names.dart';
import '../services/storage_service.dart';  // ← ADD

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _checkAuthAndNavigate();  // ← Changed
  }

  // ==========================
  // AUTO-LOGIN CHECK
  // ==========================
  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check if user is logged in
    final isLoggedIn = await StorageService.isLoggedIn();

    if (isLoggedIn) {
      // User already logged in → go to Home
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else {
      // Not logged in → go to Onboarding
      Navigator.pushReplacementNamed(context, RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.confirmation_number,
                          color: AppColors.primary,
                          size: 65,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.tagline,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: AppColors.white.withValues(alpha: 0.8),
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      AppStrings.splashTagline,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}