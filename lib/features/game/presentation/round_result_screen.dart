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
import '../../../shared/widgets/common/player_avatar.dart';

/// Tur sonu ekranı — Oylama sonucu ve kazanılan/kaybedilen puan.
class RoundResultScreen extends ConsumerWidget {
  const RoundResultScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(watchGameProvider(gameId));
    final playersAsync = ref.watch(watchPlayersProvider(roomCode));

    return Scaffold(
      body: gameAsync.when(
        data: (game) {
          if (game == null) return const Center(child: CircularProgressIndicator());

          final earnedScore = game.lastRoundScore ?? 0;
          final multiplier = game.lastRoundMultiplier ?? 1;
          final isPass = multiplier == 0;
          final isGameOver = game.status == GameStatus.finished;

          String playerName = game.currentPlayerId;
          if (playersAsync.value != null) {
            try {
              playerName = playersAsync.value!.firstWhere((p) => p.id == game.currentPlayerId).name;
            } catch (_) {}
          }

          // Navigate non-hosts automatically when next round starts
          ref.listen<AsyncValue<GameEntity?>>(
            watchGameProvider(gameId),
            (previous, next) {
              if (!context.mounted) return;
              final previousStatus = previous?.value?.status;
              final currentStatus = next.value?.status;
              
              if (previousStatus == GameStatus.results && 
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

          return GradientContainer(
            padding: EdgeInsets.zero,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: earnedScore >= 0
                            ? AppColors.votePositive.withValues(alpha: 0.15)
                            : AppColors.voteNegative.withValues(alpha: 0.15),
                      ),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Center(
                          child: Text(
                            earnedScore >= 0 ? '🎉' : '😬',
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      isPass ? 'Görev Pas Geçildi!' : 'Tur Tamamlandı!',
                      style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$playerName ${isPass ? 'görevi pas geçti ve ceza aldı.' : 'görevini yaptı.'}',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (!isPass) ...[
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
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(color: Colors.white12),
                              ),
                              _ScoreRow(
                                label: 'Çarpan',
                                value: '×$multiplier',
                                color: AppColors.accent,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(color: Colors.white12),
                              ),
                            ],
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
                    const SizedBox(height: 16),

                    // Liderlik Tablosu
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: playersAsync.when(
                        data: (players) {
                          final sortedPlayers = List.of(players)..sort((a, b) => b.score.compareTo(a.score));
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                                child: Text(
                                  '🏆 Liderlik Tablosu',
                                  style: AppTextStyles.titleMedium.copyWith(color: Colors.white70),
                                ),
                              ),
                              ...List.generate(sortedPlayers.length, (index) {
                                final player = sortedPlayers[index];
                                final isMe = player.id == game.currentPlayerId;
                                
                                Color rankColor;
                                if (index == 0) {
                                  rankColor = const Color(0xFFFFD700);
                                } else if (index == 1) {
                                  rankColor = const Color(0xFFC0C0C0);
                                } else if (index == 2) {
                                  rankColor = const Color(0xFFCD7F32);
                                } else {
                                  rankColor = Colors.white38;
                                }

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: isMe ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isMe ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            child: Text(
                                              '#${index + 1}',
                                              style: AppTextStyles.titleMedium.copyWith(
                                                color: rankColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          PlayerAvatar(
                                            displayName: player.name,
                                            avatarUrl: player.avatarUrl,
                                            radius: 14,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              player.name,
                                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '${player.score}',
                                            style: AppTextStyles.titleMedium.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                            ],
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(child: Text('Skorlar yüklenemedi: $e')),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Consumer(
                      builder: (context, ref, child) {
                        final roomAsync = ref.watch(watchRoomProvider(roomCode));
                        final user = ref.watch(currentUserProvider);
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
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }
                      }
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Hata: $e')),
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
