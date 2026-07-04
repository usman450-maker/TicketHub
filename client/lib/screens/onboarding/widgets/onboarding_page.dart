import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'page_indicator.dart';

class OnboardingPage extends StatelessWidget {
  final Map<String, String> data;
  final int currentPage;
  final int totalPages;
  final bool isLastPage;
  final VoidCallback onNext;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.isLastPage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.network(
            data['image']!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.primary.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.primaryLight,
            ),
          ),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),

        // Bottom Card
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PageIndicator(
                  currentPage: currentPage,
                  totalPages: totalPages,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  data['title']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  data['subtitle']!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage
                              ? AppStrings.getStarted
                              : AppStrings.next,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Step ${currentPage + 1} of $totalPages',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}