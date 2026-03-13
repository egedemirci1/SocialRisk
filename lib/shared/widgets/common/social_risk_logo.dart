import 'package:flutter/material.dart';
import 'package:social_risk/core/constants/app_colors.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

enum LogoMode { full, onlyIcon, onlyText }

class SocialRiskLogo extends StatelessWidget {
  final double height;
  final LogoMode mode;
  final bool showGlow;

  const SocialRiskLogo({
    super.key,
    this.height = 100,
    this.mode = LogoMode.full,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (mode != LogoMode.onlyText) _buildIcon(),
        if (mode == LogoMode.full) SizedBox(height: height * 0.12),
        if (mode != LogoMode.onlyIcon) _buildLogotype(),
      ],
    );
  }

  Widget _buildIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glow
        if (showGlow)
          Container(
            height: height * 0.65,
            width: height * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: height * 0.4,
                  spreadRadius: height * 0.05,
                ),
              ],
            ),
          ),
        // Gradient Ring
        Container(
          height: height * 0.6,
          width: height * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.accentGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(height * 0.06),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            alignment: Alignment.center,
            child: Text(
              'S',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.primary,
                fontSize: height * 0.35,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogotype() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'SOCIAL',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: height * (mode == LogoMode.onlyText ? 0.4 : 0.22),
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          TextSpan(
            text: 'RISK',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontSize: height * (mode == LogoMode.onlyText ? 0.4 : 0.22),
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
