import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

/// Animasyonlu puan sayacı — puan değiştiğinde animasyonlu geçiş.
class ScoreCounter extends StatelessWidget {
  const ScoreCounter({
    super.key,
    required this.score,
    this.delta,
    this.textStyle,
  });

  final int score;
  final int? delta;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
        const SizedBox(width: 4),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: score),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Text(
              '$value',
              style: textStyle ??
                  AppTextStyles.titleMedium.copyWith(fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,),
            );
          },
        ),
        if (delta != null && delta != 0) ...[
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: delta! > 0
                  ? AppColors.votePositive.withValues(alpha: 0.15)
                  : AppColors.penalty.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                delta! > 0 ? '+$delta' : '$delta',
                style: AppTextStyles.labelSmall.copyWith(fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: delta! > 0
                      ? AppColors.votePositive
                      : AppColors.penalty,),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
