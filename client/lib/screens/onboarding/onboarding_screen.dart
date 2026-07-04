import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image':
          'https://images.unsplash.com/photo-1616530940355-351fabd9524b?w=800',
      'title': 'Seamless Booking',
      'subtitle':
          'Secure your tickets in seconds with our premium booking experience.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
      'title': 'Discover Experiences',
      'subtitle':
          'Explore a world of movies, events, and travel at your fingertips.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=800',
      'title': 'Travel in Style',
      'subtitle':
          'From private jets to front-row seats, experience the pinnacle of luxury.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: _pages[index],
                currentPage: _currentPage,
                totalPages: _pages.length,
                isLastPage: index == _pages.length - 1,
                onNext: _nextPage,
              );
            },
          ),

          // Skip Button - Top Right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 20),
                child: GestureDetector(
                  onTap: _goToLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      AppStrings.skip,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}