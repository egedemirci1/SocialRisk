import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/enums.dart';
import '../../../../core/constants/app_text_styles.dart';

class TurnCounterBadge extends StatelessWidget {
  const TurnCounterBadge({
    super.key,
    required this.currentRound,
    required this.endConditionType,
    required this.endConditionValue,
  });

  final int currentRound;
  final EndConditionType endConditionType;
  final int endConditionValue;

  @override
  Widget build(BuildContext context) {
    bool isRounds = endConditionType == EndConditionType.rounds;
    String text = isRounds
        ? '$currentRound / $endConditionValue Tur'
        : '$currentRound. Tur • $endConditionValue P'; // Compacted for better fit


    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.accent,
            fontSize: 12, // Increased from default for better visibility
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
