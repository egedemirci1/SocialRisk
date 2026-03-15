import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/score/leaderboard_tile.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';

/// Oyun sonu ekranı — Parti Temalı
class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  static const List<int> _rankRewards = [200, 100, 50];
  static const int _defaultReward = 20;

  static int rewardForRank(int rank, int totalPlayers) {
    if (rank <= _rankRewards.length) return _rankRewards[rank - 1];
    return _defaultReward;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: playersAsync.when(
        data: (players) {
          final sorted = List.of(players)
            ..sort((a, b) => b.score.compareTo(a.score));
          final winner = sorted.isNotEmpty ? sorted.first : null;

          final myPlayer = user != null
              ? sorted.where((p) => p.id == user.uid).firstOrNull
              : null;
          final myRank = user != null
              ? sorted.indexWhere((p) => p.id == user.uid) + 1
              : 0;
          final hasNegativeScore = myPlayer != null && myPlayer.score <= 0;
          final myReward = (myRank > 0 && !hasNegativeScore)
              ? rewardForRank(myRank, sorted.length)
              : 0;

          return SafeArea(
            child: ResponsiveWrapper(
              maxWidth: 600,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  const Spacer(),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 72)),
                        const SizedBox(height: 16),
                        Text(
                          'KAZANAN',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          winner?.name.toUpperCase() ?? '',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${winner?.score ?? 0} PUAN',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.leaderboard_rounded,
                          color: Colors.white24,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'OYUNCU SIRALAMASI',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white54,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final p = sorted[index];
                        return LeaderboardTile(
                          rank: index + 1,
                          playerName: p.name,
                          score: p.score,
                          isCurrentPlayer: p.id == user?.uid,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasNegativeScore
                                    ? Icons.sentiment_very_dissatisfied_rounded
                                    : Icons.stars_rounded,
                                color: hasNegativeScore
                                    ? AppColors.primary
                                    : AppColors.accent,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                  child: Text(
                                    hasNegativeScore
                                        ? 'Eksilere düşmezsin be kardeşim\nHiç bakiye kazanamadın!'
                                        : '+$myReward Puan Bakiyenize Eklendi',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: hasNegativeScore
                                          ? Colors.white70
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        StageButton(
                          label: 'LOBİYE DÖN',
                          icon: Icons.home_rounded,
                          backgroundColor: AppColors.surface,
                          textColor: Colors.white,
                          borderColor: AppColors.accent.withValues(
                            alpha: 0.3,
                          ),
                          onPressed: () => context.go('/home'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
