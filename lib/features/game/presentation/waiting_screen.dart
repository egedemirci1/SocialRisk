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
      final user = ref.read(currentUserProvider);

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
            } else if (nextGame.status == GameStatus.playing &&
                       nextGame.currentPlayerId == user?.uid) {
              // Sadece sırası gelen oyuncu /task'a gider
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

        // Güvenlik kontrolü: Eğer bu benim sıramsa ve status=playing ise /task'a git
        final user = ref.read(currentUserProvider);
        if (game.status == GameStatus.playing &&
            game.currentPlayerId == user?.uid) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.replace('/task', extra: {
                'gameId': widget.gameId,
                'roomCode': widget.roomCode,
              });
            }
          });
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
          backgroundColor: const Color(0xFF140D0B),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded, color: Color(0xFFD4AF37)),
                onPressed: () => ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/Loading-Screen-Background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
              Container(color: const Color(0xFF140D0B).withOpacity(0.85)),
              SafeArea(
                child: Padding(
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
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          ),
                          child: const SizedBox(
                            width: 120,
                            height: 120,
                            child: Center(
                              child: Icon(
                                Icons.hourglass_top_rounded,
                                color: Color(0xFFD4AF37),
                                size: 56,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Bekleniyor...',
                        style: GoogleFonts.cinzelDecorative(
                          color: const Color(0xFFFDEFC2),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        game.status == GameStatus.performing
                            ? '$currentPlayerName görevini yapıyor'
                            : '$currentPlayerName çarkı çeviriyor',
                        style: GoogleFonts.cinzel(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E140F).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: Color(0xFFD4AF37), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Görev bitince oylama başlayacak',
                                style: GoogleFonts.cinzel(
                                  color: Colors.white38,
                                  fontSize: 13,
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
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }
}
