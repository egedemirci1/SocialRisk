import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/score/score_counter.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';

/// Tur sonu ekranı — Oylama sonucu ve kazanılan/kaybedilen puan.
class RoundResultScreen extends ConsumerWidget {
  const RoundResultScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
    required this.earnedScore,
    required this.multiplier,
  });

  final String gameId;
  final String roomCode;
  final int earnedScore;
  final int multiplier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),

            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.votePositive.withValues(alpha: 0.15),
              ),
              child: const SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: Text('🎉', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Tur Tamamlandı!',
              style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 32),

            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _ScoreRow(
                      label: 'Oylama Skoru',
                      value: '+${earnedScore ~/ multiplier}',
                      color: AppColors.votePositive,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white12),
                    ),
                    _ScoreRow(
                      label: 'Çarpan',
                      value: '×$multiplier',
                      color: AppColors.accent,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white12),
                    ),
                    _ScoreRow(
                      label: 'Kazanılan Puan',
                      value: '+$earnedScore',
                      color: AppColors.accent,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bu tur: ',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                ),
                ScoreCounter(score: earnedScore, delta: earnedScore),
              ],
            ),

            const Spacer(flex: 2),

            PrimaryButton(
              label: 'Sıradaki Tura Geç',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                context.go('/waiting', extra: {
                  'gameId': gameId,
                  'roomCode': roomCode,
                });
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
        ),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: color,
            fontSize: isBold ? 22 : 18,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
