import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';

/// Bekleme ekranı — Diğer oyuncuların görevi tamamlamasını bekle.
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
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
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

    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (previous, next) {
      if (!mounted) return;
      final nextGame = next.value;
      final prevGame = previous?.value;
      
      if (nextGame != null && prevGame?.status != nextGame.status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (nextGame.status == GameStatus.finished) {
              context.replace('/game-over', extra: widget.roomCode);
            } else if (nextGame.status == GameStatus.voting) {
              context.replace('/voting', extra: {
                'gameId': widget.gameId,
                'roomCode': widget.roomCode,
              });
            } else if (nextGame.status == GameStatus.results) {
              context.replace('/round-result', extra: {
                'gameId': widget.gameId,
                'roomCode': widget.roomCode,
              });
            } else if (nextGame.status == GameStatus.playing) {
              context.replace('/task', extra: {
                'gameId': widget.gameId,
                'roomCode': widget.roomCode,
              });
            }
          }
        });
      }
    });

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // Aktif oyuncunun ismini bul
        final playerNames = <String, String>{};
        if (playersAsync.value != null) {
          for (final p in playersAsync.value!) {
            playerNames[p.id] = p.name;
          }
        }
        final currentPlayerName =
            playerNames[game.currentPlayerId] ?? game.currentPlayerId;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded),
                onPressed: () => ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: GradientContainer(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                ScaleTransition(
                  scale: _pulseAnimation,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                    child: const SizedBox(
                      width: 120,
                      height: 120,
                      child: Center(
                        child: Icon(
                          Icons.hourglass_top_rounded,
                          color: AppColors.accent,
                          size: 56,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Bekleniyor...',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  game.status == GameStatus.performing
                      ? '$currentPlayerName görevini yapıyor'
                      : '$currentPlayerName çarkı çeviriyor',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.white38, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Görev bitince oylama başlayacak',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),
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
