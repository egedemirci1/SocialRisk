import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/score/leaderboard_tile.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../../core/constants/app_colors.dart';

/// Oyun sonu ekranı — Tiyatro Temalı
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
      backgroundColor: AppColors.background,
      body: playersAsync.when(
        data: (players) {
          final sorted = List.of(players)
            ..sort((a, b) => b.score.compareTo(a.score));
          final winner = sorted.isNotEmpty ? sorted.first : null;
          final myScore = user != null
              ? (players.where((p) => p.id == user.uid).firstOrNull?.score ?? 0)
              : 0;

          return SafeArea(
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
                        'BAŞROLDE',
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        winner?.name.toUpperCase() ?? '',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${winner?.score ?? 0} ALKIŞ',
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.accent,
                          fontSize: 24,
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
                        'AKTÖR SIRALAMASI',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white54,
                          fontSize: 13,
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
                            const Icon(
                              Icons.stars_rounded,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                '+$myScore Alkış Bakiyenize Eklendi',
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StageButton(
                              label: 'GİŞEYE GİT',
                              icon: Icons.storefront_rounded,
                              backgroundColor: AppColors.surface,
                              textColor: Colors.white,
                              borderColor: AppColors.accent.withValues(
                                alpha: 0.3,
                              ),
                              onPressed: () => context.push('/store'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StageButton(
                              label: 'FUAYEYE DÖN',
                              icon: Icons.home_rounded,
                              backgroundColor: AppColors.primary,
                              textColor: Colors.white,
                              borderColor:
                                  AppColors.accent, // Added borderColor
                              onPressed: () => context.go('/home'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12), // Added SizedBox for spacing
                      StageButton(
                        label: 'TEKRAR OYNA',
                        backgroundColor: AppColors.primary,
                        textColor: Colors.white,
                        borderColor: AppColors.accent,
                        onPressed: () => context.go('/lobby'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
