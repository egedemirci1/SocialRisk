import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/score/score_counter.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../providers/game_provider.dart';
import '../domain/game_entity.dart';
import '../../room/providers/room_provider.dart';
import '../../auth/providers/auth_provider.dart';

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
    final gameAsync = ref.watch(watchGameProvider(gameId));

    return Scaffold(
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),

            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: earnedScore >= 0
                    ? AppColors.votePositive.withValues(alpha: 0.15)
                    : AppColors.voteNegative.withValues(alpha: 0.15),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: Text(
                    earnedScore >= 0 ? '🎉' : '😬',
                    style: const TextStyle(fontSize: 48),
                  ),
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
                      value: multiplier != 0
                          ? '${earnedScore ~/ multiplier}'
                          : '$earnedScore',
                      color: earnedScore >= 0
                          ? AppColors.votePositive
                          : AppColors.voteNegative,
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
                      label: earnedScore >= 0
                          ? 'Kazanılan Puan'
                          : 'Kaybedilen Puan',
                      value: earnedScore >= 0
                          ? '+$earnedScore'
                          : '$earnedScore',
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
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white54),
                ),
                ScoreCounter(score: earnedScore, delta: earnedScore),
              ],
            ),

            const Spacer(flex: 2),

            gameAsync.when(
              data: (game) {
                final isGameOver = game?.status == GameStatus.finished;
                
                // Navigate non-hosts automatically when next round starts
                ref.listen<AsyncValue<GameEntity?>>(
                  watchGameProvider(gameId),
                  (previous, next) {
                    if (!context.mounted) return;
                    final previousStatus = previous?.value?.status;
                    final currentStatus = next.value?.status;
                    
                    if (previousStatus == GameStatus.voting && 
                        currentStatus == GameStatus.playing) {
                      context.go('/waiting', extra: {
                        'gameId': gameId,
                        'roomCode': roomCode,
                      });
                    } else if (currentStatus == GameStatus.finished) {
                      context.go('/game-over', extra: roomCode);
                    }
                  }
                );

                return Consumer(
                  builder: (context, ref, child) {
                    final roomAsync = ref.watch(watchRoomProvider(roomCode));
                    final user = ref.read(authControllerProvider).value;
                    final isHost = roomAsync.value?.hostId == user?.uid;

                    if (isHost) {
                      return PrimaryButton(
                        label: isGameOver ? 'Sonuçları Gör' : 'Sıradaki Tura Geç',
                        icon: isGameOver
                            ? Icons.emoji_events_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: () async {
                          if (isGameOver) {
                            context.go('/game-over', extra: roomCode);
                          } else {
                            // Host trigger next turn
                            await ref.read(gameControllerProvider.notifier).nextTurn(gameId);
                          }
                        },
                      );
                    } else {
                      return Column(
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            isGameOver ? 'Oyun bitti, sonuçlar bekleniyor...' : 'Hostun sıradaki tura geçmesi bekleniyor...',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                          ),
                        ],
                      );
                    }
                  }
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Hata: $e'),
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
