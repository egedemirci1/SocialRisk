import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/voting/voting_panel.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../game/providers/game_provider.dart';
import '../providers/vote_provider.dart';

/// Oylama ekranı — Diğer oyuncular aktif oyuncuyu oyluyor.
class VotingScreen extends ConsumerWidget {
  const VotingScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(watchGameProvider(gameId));
    final user = ref.watch(currentUserProvider);
    final votesAsync = ref.watch(watchVotesProvider(gameId));

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final performerName = game.currentPlayerId; // Adı player listesinden almak gerekiyor — şimdilik ID
        final task = game.currentTask;
        final myVote = votesAsync.value?[user?.uid];
        final allVoted = votesAsync.value != null &&
            game.turnOrder.every(
              (id) => id == game.currentPlayerId || votesAsync.value!.containsKey(id),
            );

        // Herkes oy verince otomatik sonuç ekranına geç
        if (allVoted) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final earned = await ref
                .read(voteControllerProvider.notifier)
                .calculateAndApplyScore(
                  gameId: gameId,
                  taskMultiplier: task?.multiplier ?? 1,
                );

            await ref.read(gameControllerProvider.notifier).applyScoreAndNextTurn(
              gameId: gameId,
              roomId: roomCode,
              playerId: game.currentPlayerId,
              scoreToAdd: earned,
              endConditionValue: 10,
              endConditionType: EndConditionType.rounds,
              currentRound: game.currentRound,
            );

            if (context.mounted) {
              if (game.status == GameStatus.finished) {
                context.go('/game-over', extra: roomCode);
              } else {
                context.go('/round-result', extra: {
                  'gameId': gameId,
                  'roomCode': roomCode,
                  'earnedScore': earned,
                  'multiplier': task?.multiplier ?? 1,
                });
              }
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Oylama'),
            automaticallyImplyLeading: false,
          ),
          body: GradientContainer(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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

                if (user?.uid == game.currentPlayerId)
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
                            gameId: gameId,
                            voterId: user.uid,
                            value: voteValue,
                          );
                    },
                  ),

                const SizedBox(height: 32),
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
