import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../providers/game_provider.dart';
import '../domain/game_entity.dart';
import '../../room/providers/room_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/providers/task_provider.dart'; // Yeni eklendi 
import '../../../shared/widgets/common/player_avatar.dart';
import 'package:lottie/lottie.dart';

/// Tur sonu ekranı — Oylama sonucu ve kazanılan/kaybedilen puan.
class RoundResultScreen extends ConsumerStatefulWidget {
  const RoundResultScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<RoundResultScreen> createState() => _RoundResultScreenState();
}

class _RoundResultScreenState extends ConsumerState<RoundResultScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));

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
            watchGameProvider(widget.gameId),
            (previous, next) {
              if (!context.mounted) return;
              final previousStatus = previous?.value?.status;
              final currentStatus = next.value?.status;
              
              if (previousStatus == GameStatus.results && 
                  currentStatus == GameStatus.playing) {
                  context.go('/waiting', extra: {
                    'gameId': widget.gameId,
                    'roomCode': widget.roomCode,
                  });
                } else if (currentStatus == GameStatus.finished) {
                  context.go('/game-over', extra: widget.roomCode);
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
                                            score: player.score,
                                            frameId: player.activeFrame,
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
                    
                    // Görev Feedback Alanı
                    if (game.currentTask != null)
                      _TaskFeedbackSection(
                        taskId: game.currentTask!.id,
                        taskContent: game.currentTask!.content,
                        gameId: widget.gameId,
                      ),
                      
                    const SizedBox(height: 24),

                    Consumer(
                      builder: (context, ref, child) {
                        final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));
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
                                context.go('/game-over', extra: widget.roomCode);
                              } else {
                                await ref.read(gameControllerProvider.notifier).nextTurn(widget.gameId);
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
      
      // Lottie overlay
      floatingActionButton: gameAsync.value?.lastRoundScore != null && gameAsync.value!.lastRoundScore! > 0
          ? IgnorePointer(
              child: Lottie.asset(
                'assets/lotties/confetti.json',
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController
                    ..duration = composition.duration
                    ..forward(from: 0.0);
                },
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

class _TaskFeedbackSection extends ConsumerStatefulWidget {
  final String taskId;
  final String taskContent;
  final String gameId;

  const _TaskFeedbackSection({
    required this.taskId,
    required this.taskContent,
    required this.gameId,
  });

  @override
  ConsumerState<_TaskFeedbackSection> createState() => _TaskFeedbackSectionState();
}

class _TaskFeedbackSectionState extends ConsumerState<_TaskFeedbackSection> {
  bool? _givenFeedback; // true = like, false = dislike, null = none

  Future<void> _submitFeedback(bool isLike) async {
    if (_givenFeedback != null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _givenFeedback = isLike);

    await ref.read(taskControllerProvider.notifier).submitFeedback(
      taskId: widget.taskId,
      userId: user.uid,
      isLike: isLike,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Görevi Değerlendir',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '"${widget.taskContent}"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeedbackButton(
                  icon: Icons.thumb_up_rounded,
                  label: 'İyiydi',
                  isActive: _givenFeedback == true,
                  isDisabled: _givenFeedback != null && _givenFeedback != true,
                  activeColor: AppColors.votePositive,
                  onTap: () => _submitFeedback(true),
                ),
                const SizedBox(width: 16),
                _FeedbackButton(
                  icon: Icons.thumb_down_rounded,
                  label: 'Kötü',
                  isActive: _givenFeedback == false,
                  isDisabled: _givenFeedback != null && _givenFeedback != false,
                  activeColor: AppColors.voteNegative,
                  onTap: () => _submitFeedback(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDisabled;
  final Color activeColor;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDisabled,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? activeColor
        : isDisabled
            ? Colors.white24
            : Colors.white54;

    return InkWell(
      onTap: isDisabled || isActive ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
