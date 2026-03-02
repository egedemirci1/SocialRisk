import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/medieval_button.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../room/domain/room_entity.dart';
import '../providers/game_provider.dart';
import 'widgets/player_spotlight.dart';
import 'widgets/spectator_strip.dart';

/// Görevi yapma ekranı — Görevi kabul eden kişi yapar, diğerleri izler/bekler (Orta Çağ Temalı).
class PerformingScreen extends ConsumerStatefulWidget {
  const PerformingScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<PerformingScreen> createState() => _PerformingScreenState();
}

class _PerformingScreenState extends ConsumerState<PerformingScreen> {
  bool _isProceeding = false;

  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

  Future<void> _proceedToVoting() async {
    setState(() => _isProceeding = true);
    try {
      await ref
          .read(gameControllerProvider.notifier)
          .proceedToVoting(widget.gameId);
      // Kendi ekranı otomatik snapshot dinleyecek ama yine de anında geçmesi için:
      if (mounted) {
        context.push(
          '/voting',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
      }
    } finally {
      if (mounted) setState(() => _isProceeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Navigate non-active players automatically when voting starts
    ref.listen(watchGameProvider(widget.gameId), (previous, next) {
      if (!mounted) return;
      final game = next.value;
      if (game == null) return;

      final prevGame = previous?.value;

      final user = ref.read(currentUserProvider);
      final isMyTurn = game.currentPlayerId == user?.uid;

      if (!isMyTurn &&
          game.status == GameStatus.voting &&
          prevGame?.status != GameStatus.voting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(
              '/voting',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          }
        });
      }
    });

    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));
    final user = ref.watch(currentUserProvider);

    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          'Sosyal Risk',
          style: GoogleFonts.cinzelDecorative(
            fontWeight: FontWeight.w700,
            color: _textLight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: gameAsync.when(
                data: (game) {
                  if (game == null) {
                    return Center(
                      child: CircularProgressIndicator(color: _accentGold),
                    );
                  }

                  final isMyTurn = game.currentPlayerId == user?.uid;
                  final task = game.currentTask;
                  final isClosed =
                      roomAsync.value?.visibility == RoomVisibility.closed;

                  // Oyuncu bilgilerini al
                  PlayerEntity? currentPlayer;
                  List<PlayerEntity> players = [];
                  if (playersAsync.value != null) {
                    players = playersAsync.value!;
                    try {
                      currentPlayer = players.firstWhere(
                        (p) => p.id == game.currentPlayerId,
                      );
                    } catch (_) {}
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),

                            if (currentPlayer != null)
                              PlayerSpotlight(
                                player: currentPlayer,
                                isMe: isMyTurn,
                              ),

                            const SizedBox(height: 32),

                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: _cardColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _accentGold.withOpacity(0.5),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      isMyTurn
                                          ? 'Görevin Ne İdi?'
                                          : 'Sıradaki Görev',
                                      style: GoogleFonts.cinzel(
                                        color: _accentGold,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      isClosed && !isMyTurn
                                          ? '❓ Gizli Görev İçeriği'
                                          : (task?.content ?? 'Bilinmiyor'),
                                      style: GoogleFonts.cinzelDecorative(
                                        color: _textLight,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),

                            if (isMyTurn) ...[
                              Text(
                                'Görevi tamamladıktan sonra oylamayı başlatabilirsiniz.',
                                style: GoogleFonts.cinzel(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              MedievalButton(
                                label: 'Görevi Tamamladım! Oylamaya Geç',
                                icon: Icons.how_to_vote_rounded,
                                backgroundColor: _accentCrimson,
                                textColor: _textLight,
                                borderColor: _accentGold,
                                isLoading: _isProceeding,
                                onPressed: _proceedToVoting,
                              ),
                            ] else ...[
                              CircularProgressIndicator(color: _accentGold),
                              const SizedBox(height: 24),
                              Text(
                                'Sırası gelen oyuncunun görevi yapması bekleniyor...',
                                style: GoogleFonts.cinzel(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const Spacer(flex: 2),
                          ],
                        ),
                      ),

                      if (players.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24, top: 8),
                          child: SpectatorStrip(
                            players: players,
                            currentPlayerId: game.currentPlayerId,
                            myPlayerId: user?.uid,
                          ),
                        ),
                    ],
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: _accentGold),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Hata: $e',
                    style: GoogleFonts.cinzel(color: _accentCrimson),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
