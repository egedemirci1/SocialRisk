import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../core/constants/app_colors.dart';

/// Bekleme ekranı — Tiyatro Temalı
class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));

    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      if (!mounted) return;
      final nextGame = next.value;
      if (nextGame != null && previous?.value?.status != nextGame.status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (nextGame.status == GameStatus.finished) {
              context.replace('/game-over', extra: widget.roomCode);
            } else if (nextGame.status == GameStatus.voting) {
              context.replace(
                '/voting',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextGame.status == GameStatus.results) {
              context.replace(
                '/round-result',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextGame.status == GameStatus.playing &&
                nextGame.currentPlayerId ==
                    ref.read(currentUserProvider)?.uid) {
              context.replace(
                '/task',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
          }
        });
      }
    });

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final players = playersAsync.value ?? [];
        final currentPlayer = players
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final playerName = currentPlayer?.name ?? 'Aktör';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.leaderboard_rounded,
                  color: AppColors.accent,
                ),
                onPressed: () =>
                    ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withValues(alpha: 0.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.theater_comedy_rounded,
                          color: AppColors.accent,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'KULİS SIRASI',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.status == GameStatus.performing
                        ? '$playerName performansını sergiliyor...'
                        : '$playerName rolünü belirliyor...',
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.white54,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sıra bittiğinde alkış tufanı başlayacak',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white30,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Hata: $e')),
      ),
    );
  }
}
