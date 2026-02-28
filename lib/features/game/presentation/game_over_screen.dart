import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/score/leaderboard_tile.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';

/// Oyun sonu ekranı — Kazanan ve sıralama tablosu.
class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final Animation<double> _scaleAnimation;

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
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final user = ref.watch(currentUserProvider);

    return playersAsync.when(
      data: (players) {
        // Puana göre sırala
        final sorted = List.of(players)
          ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

        final winner = sorted.isNotEmpty ? sorted.first : null;

        return Scaffold(
          body: GradientContainer(
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
                        'KAZANAN!',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.accent,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        winner?.name ?? '',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${winner?.score ?? 0} puan',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

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

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final player = sorted[index];
                      return LeaderboardTile(
                        rank: index + 1,
                        playerName: player.name,
                        score: player.score ?? 0,
                        isCurrentPlayer: player.id == user?.uid,
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: PrimaryButton(
                    label: 'Ana Menüye Dön',
                    icon: Icons.home_rounded,
                    onPressed: () => context.go('/home'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }
}
