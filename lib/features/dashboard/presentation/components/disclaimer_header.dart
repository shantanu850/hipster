import 'package:flutter/material.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';

class DisclaimerHeader extends StatelessWidget {
  const DisclaimerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/logo.png',
            width: 64,
            height: 64,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.code_rounded,
              color: AppColors.secondary,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          AppStrings.developerDisclaimerTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
