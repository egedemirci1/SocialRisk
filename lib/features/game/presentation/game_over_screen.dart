import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/score/leaderboard_tile.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';

/// Oyun sonu ekranı — Kazanan ve sıralama tablosu.
class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final Animation<double> _scaleAnimation;

  // Mock veri
  final List<_MockPlayerScore> _players = [
    const _MockPlayerScore(name: 'Oyuncu 1', score: 3200, isCurrentPlayer: true),
    const _MockPlayerScore(name: 'Oyuncu 2', score: 2800, isCurrentPlayer: false),
    const _MockPlayerScore(name: 'Oyuncu 3', score: 1500, isCurrentPlayer: false),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.elasticOut,
    );
    _confettiController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = _players.first;

    return Scaffold(
      body: GradientContainer(
        child: Column(
          children: [
            const Spacer(),

            // Kazanan bölümü
            ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  const Text(
                    '🏆',
                    style: TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'KAZANAN!',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    winner.name,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${winner.score} puan',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Sıralama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.leaderboard_rounded,
                      color: Colors.white38, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Final Sıralaması',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Oyuncu listesi
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  return LeaderboardTile(
                    rank: index + 1,
                    playerName: player.name,
                    score: player.score,
                    isCurrentPlayer: player.isCurrentPlayer,
                  );
                },
              ),
            ),

            // Ana menüye dön
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: PrimaryButton(
                label: 'Ana Menüye Dön',
                icon: Icons.home_rounded,
                onPressed: () {
                  // TODO: GoRouter ile /home'a git
                  debugPrint('Ana menüye dön');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPlayerScore {
  const _MockPlayerScore({
    required this.name,
    required this.score,
    required this.isCurrentPlayer,
  });
  final String name;
  final int score;
  final bool isCurrentPlayer;
}
