import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const LogoWidget({
    super.key,
    this.size = 60,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(
            Icons.confirmation_number,
            color: AppColors.primary,
            size: size * 0.55,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 6),
          const Text(
            'TicketHub',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}