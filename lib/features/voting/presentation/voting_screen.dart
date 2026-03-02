import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/voting/voting_panel.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../game/providers/game_provider.dart';
import '../providers/vote_provider.dart';
import '../../game/domain/game_entity.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../shared/widgets/common/player_avatar.dart';

/// Oylama ekranı — Diğer oyuncular aktif oyuncuyu oyluyor (Orta Çağ Temalı).
class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key, required this.gameId, required this.roomCode});

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  bool _isProcessing = false;

  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu
  static const _accentCrimson = Color(0xFF5C1616); // Bordo

  Future<void> _processResults({
    required String currentPlayerId,
    required int taskMultiplier,
    required int currentRound,
  }) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Oy sonucunu hesapla
      final earned = await ref
          .read(voteControllerProvider.notifier)
          .calculateAndApplyScore(
            gameId: widget.gameId,
            taskMultiplier: taskMultiplier,
          );

      // Oda ayarlarından bitiş koşulunu al
      final roomAsync = ref.read(watchRoomProvider(widget.roomCode));
      final room = roomAsync.value;
      final endConditionType =
          room?.endConditionType ?? EndConditionType.rounds;
      final endConditionValue = room?.endConditionValue ?? 10;

      // Puanı uygula
      await ref
          .read(gameControllerProvider.notifier)
          .applyScore(
            gameId: widget.gameId,
            roomId: widget.roomCode,
            playerId: currentPlayerId,
            scoreToAdd: earned,
            taskMultiplier: taskMultiplier,
            endConditionValue: endConditionValue,
            endConditionType: endConditionType,
            currentRound: currentRound,
          );

      if (!mounted) return;

      // Navigation is now handled by ref.listen on GameStatus change
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: $e',
              style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
            ),
            backgroundColor: _accentCrimson,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final user = ref.watch(currentUserProvider);
    final votesAsync = ref.watch(watchVotesProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return Scaffold(
            backgroundColor: _bgColor,
            body: Center(child: CircularProgressIndicator(color: _accentGold)),
          );
        }

        // Oyuncu isimlerini map olarak hazırla
        final playerNames = <String, String>{};
        final activePlayers = playersAsync.value ?? [];
        for (final p in activePlayers) {
          playerNames[p.id] = p.name;
        }

        // Listen for game status changes to navigate to results or game over
        ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
          previous,
          next,
        ) {
          final currentStatus = next.value?.status;
          if (currentStatus == GameStatus.results) {
            context.go(
              '/round-result',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          } else if (currentStatus == GameStatus.finished) {
            context.go('/game-over', extra: widget.roomCode);
          }
        });

        final performerName =
            playerNames[game.currentPlayerId] ?? game.currentPlayerId;
        final task = game.currentTask;
        final myVote = votesAsync.value?[user?.uid];

        // Check if all ACTIVE players (not turnOrder) have voted
        final activePlayerIds = activePlayers.map((p) => p.id).toList();
        final allVoted =
            votesAsync.value != null &&
            activePlayerIds.every(
              (id) =>
                  id == game.currentPlayerId ||
                  votesAsync.value!.containsKey(id),
            );

        final isMyTurn = game.currentPlayerId == user?.uid;

        // Debug: log vote status
        debugPrint(
          'Voting: allVoted=$allVoted, isMyTurn=$isMyTurn, '
          'activePlayers=${activePlayerIds.length}, '
          'votes=${votesAsync.value?.length ?? 0}, '
          'processing=$_isProcessing',
        );

        // Herkes oy verdiyse sonuçları hesapla (tek seferlik, sadece aktif oyuncu)
        if (allVoted && !_isProcessing && isMyTurn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isProcessing) {
              _processResults(
                currentPlayerId: game.currentPlayerId,
                taskMultiplier: task?.multiplier ?? 1,
                currentRound: game.currentRound,
              );
            }
          });
        }

        return Scaffold(
          backgroundColor: _bgColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Oylama',
              style: GoogleFonts.cinzelDecorative(
                fontWeight: FontWeight.w700,
                color: _textLight,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded, color: _accentGold),
                onPressed: () =>
                    ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                const Spacer(),

                                // Show performer avatar
                                Builder(
                                  builder: (context) {
                                    final performer = activePlayers
                                        .where(
                                          (p) => p.id == game.currentPlayerId,
                                        )
                                        .toList();
                                    final avatarUrl = performer.isNotEmpty
                                        ? performer.first.avatarUrl
                                        : null;
                                    return PlayerAvatar(
                                      displayName: performerName,
                                      avatarUrl: avatarUrl,
                                      score: performer.isNotEmpty
                                          ? performer.first.score
                                          : 0,
                                      frameId: performer.isNotEmpty
                                          ? performer.first.activeFrame
                                          : null,
                                      radius: 48,
                                      showEffect: false,
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  performerName,
                                  style: GoogleFonts.cinzel(
                                    color: _textLight,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'görevini tamamladı:',
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: _cardColor.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _accentGold.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      '"${task?.content ?? ''}"',
                                      style: GoogleFonts.cinzel(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                if (_isProcessing)
                                  Column(
                                    children: [
                                      CircularProgressIndicator(
                                        color: _accentGold,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Sonuçlar hesaplanıyor...',
                                        style: GoogleFonts.cinzel(
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  )
                                else if (user?.uid == game.currentPlayerId)
                                  Text(
                                    'Diğer oyuncuların oyu bekleniyor...',
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white54,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16,
                                    ),
                                  )
                                else if (myVote != null)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.votePositive
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        'Oyun verildi ✓',
                                        style: GoogleFonts.cinzel(
                                          color: AppColors.votePositive,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  VotingPanel(
                                    onVote: (value) {
                                      if (user == null) return;
                                      final voteValue = VoteValue.values.byName(
                                        value,
                                      );
                                      ref
                                          .read(voteControllerProvider.notifier)
                                          .castVote(
                                            gameId: widget.gameId,
                                            voterId: user.uid,
                                            value: voteValue,
                                          );
                                    },
                                  ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
