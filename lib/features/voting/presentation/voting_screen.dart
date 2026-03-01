import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/voting/voting_panel.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../game/providers/game_provider.dart';
import '../providers/vote_provider.dart';
import '../../game/domain/game_entity.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';

/// Oylama ekranı — Diğer oyuncular aktif oyuncuyu oyluyor.
class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  bool _isProcessing = false;

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
      await ref.read(gameControllerProvider.notifier).applyScore(
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
          SnackBar(content: Text('Hata: $e')),
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
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // Oyuncu isimlerini map olarak hazırla
        final playerNames = <String, String>{};
        if (playersAsync.value != null) {
          for (final p in playersAsync.value!) {
            playerNames[p.id] = p.name;
          }
        }

        // Listen for game status changes to navigate to results or game over
        ref.listen<AsyncValue<GameEntity?>>(
          watchGameProvider(widget.gameId),
          (previous, next) {
            final currentStatus = next.value?.status;
            if (currentStatus == GameStatus.results) {
              context.go('/round-result', extra: {
                'gameId': widget.gameId,
                'roomCode': widget.roomCode,
              });
            } else if (currentStatus == GameStatus.finished) {
              context.go('/game-over', extra: widget.roomCode);
            }
          }
        );

        final performerName =
            playerNames[game.currentPlayerId] ?? game.currentPlayerId;
        final task = game.currentTask;
        final myVote = votesAsync.value?[user?.uid];
        
        // Check if all ACTIVE players (not turnOrder) have voted
        final activePlayers = playersAsync.value ?? [];
        final activePlayerIds = activePlayers.map((p) => p.id).toList();
        final allVoted = votesAsync.value != null &&
            activePlayerIds.every(
              (id) =>
                  id == game.currentPlayerId ||
                  votesAsync.value!.containsKey(id),
            );

        final isMyTurn = game.currentPlayerId == user?.uid;

        // Debug: log vote status
        debugPrint('Voting: allVoted=$allVoted, isMyTurn=$isMyTurn, '
            'activePlayers=${activePlayerIds.length}, '
            'votes=${votesAsync.value?.length ?? 0}, '
            'processing=$_isProcessing');

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
          appBar: AppBar(
            title: const Text('Oylama'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded),
                onPressed: () => ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          body: GradientContainer(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),

                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceElevated,
                            ),
                            child: const SizedBox(
                              width: 72,
                              height: 72,
                              child: Center(
                                child: Icon(Icons.person_rounded,
                                    color: Colors.white54, size: 36),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            performerName,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'görevini tamamladı:',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white38,
                            ),
                          ),
                          const SizedBox(height: 12),

                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                '"${task?.content ?? ''}"',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white70,
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
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                Text(
                                  'Sonuçlar hesaplanıyor...',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            )
                          else if (user?.uid == game.currentPlayerId)
                            Text(
                              'Diğer oyuncuların oyu bekleniyor...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white38,
                              ),
                            )
                          else if (myVote != null)
                            Text(
                              'Oyun verildi ✓',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.votePositive,
                              ),
                            )
                          else
                            VotingPanel(
                              onVote: (value) {
                                if (user == null) return;
                                final voteValue = VoteValue.values.byName(value);
                                ref.read(voteControllerProvider.notifier).castVote(
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
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }
}
