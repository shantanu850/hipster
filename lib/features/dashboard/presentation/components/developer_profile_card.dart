import 'package:flutter/material.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import 'social_action_button.dart';
import 'staggered_fade_slide.dart';

class DeveloperProfileCard extends StatelessWidget {
  const DeveloperProfileCard({
    super.key,
    required this.animatedCount,
    required this.onPhoneTap,
    required this.onGithubTap,
    required this.onLinkedInTap,
    required this.onPortfolioTap,
  });

  final int animatedCount;
  final VoidCallback onPhoneTap;
  final VoidCallback onGithubTap;
  final VoidCallback onLinkedInTap;
  final VoidCallback onPortfolioTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary,
            child: Text(
              'SP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.developerName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            AppStrings.developerRole,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.developerPhone,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StaggeredFadeSlide(
                isVisible: animatedCount > 0,
                child: SocialActionButton(
                  icon: Icons.phone_rounded,
                  label: AppStrings.callLabel,
                  color: AppColors.primary,
                  onTap: onPhoneTap,
                ),
              ),
              StaggeredFadeSlide(
                isVisible: animatedCount > 1,
                child: SocialActionButton(
                  icon: Icons.code_rounded,
                  label: AppStrings.githubLabel,
                  color: const Color(0xFF24292F),
                  onTap: onGithubTap,
                ),
              ),
              StaggeredFadeSlide(
                isVisible: animatedCount > 2,
                child: SocialActionButton(
                  icon: Icons.link_rounded,
                  label: AppStrings.linkedInLabel,
                  color: const Color(0xFF0A66C2),
                  onTap: onLinkedInTap,
                ),
              ),
              StaggeredFadeSlide(
                isVisible: animatedCount > 3,
                child: SocialActionButton(
                  icon: Icons.web_rounded,
                  label: AppStrings.portfolioLabel,
                  color: AppColors.secondary,
                  onTap: onPortfolioTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
