import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/score/leaderboard_tile.dart';
import '../../../shared/widgets/buttons/medieval_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';

/// Oyun sonu ekranı — Kazanan ve sıralama tablosu (Orta Çağ Temalı).
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

  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

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
          ..sort((a, b) => b.score.compareTo(a.score));

        final winner = sorted.isNotEmpty ? sorted.first : null;

        return Scaffold(
          backgroundColor: _bgColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Arka Plan Resmi
              Image.asset(
                'assets/Loading-Screen-Background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
              // Karartma (Overlay)
              Container(color: _bgColor.withOpacity(0.85)),

              SafeArea(
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
                            style: GoogleFonts.cinzelDecorative(
                              color: _textLight,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            winner?.name ?? '',
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${winner?.score ?? 0} puan',
                            style: GoogleFonts.cinzel(
                              color: _accentGold,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
                          const Icon(
                            Icons.leaderboard_rounded,
                            color: Colors.white38,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Final Sıralaması',
                            style: GoogleFonts.cinzel(
                              color: Colors.white54,
                              fontSize: 16,
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
                          // LeaderboardTile uses its own styling.
                          // It might need to be themed as well, but for now we render it.
                          // We'll wrap it if needed or theme it later.
                          return LeaderboardTile(
                            rank: index + 1,
                            playerName: player.name,
                            score: player.score,
                            isCurrentPlayer: player.id == user?.uid,
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          // Kazanılan puanları cüzdana aktarma UI'ı (A37)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: _cardColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _accentGold.withOpacity(0.5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: _accentGold,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      '+${user != null ? players.firstWhere((p) => p.id == user.uid, orElse: () => players.first).score : 0} Puan Cüzdana Eklendi',
                                      style: GoogleFonts.cinzel(
                                        color: _textLight,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: MedievalButton(
                                  label: 'Mağazaya Git',
                                  icon: Icons.storefront_rounded,
                                  backgroundColor: _cardColor,
                                  textColor: _textLight,
                                  borderColor: _accentGold,
                                  onPressed: () => context.push('/store'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MedievalButton(
                                  label: 'Odalara Dön',
                                  icon: Icons.home_rounded,
                                  backgroundColor: _accentCrimson,
                                  textColor: _textLight,
                                  borderColor: _accentGold,
                                  onPressed: () => context.go('/home'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _accentGold)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: Text(
            'Hata: $e',
            style: GoogleFonts.cinzel(color: _accentCrimson),
          ),
        ),
      ),
    );
  }
}
