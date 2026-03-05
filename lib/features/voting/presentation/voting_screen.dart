import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/voting/voting_panel.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../game/providers/game_provider.dart';
import '../providers/vote_provider.dart';
import '../../game/domain/game_entity.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../shared/widgets/buttons/leave_room_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../economy/providers/economy_provider.dart';

/// Oylama ekranı — Diğer oyuncular aktif oyuncuyu oyluyor (Tiyatro Temalı).
class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key, required this.gameId, required this.roomCode});

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  bool _isProcessing = false;
  bool _hasProcessed = false;
  bool _hasVoted = false;

  Future<void> _processResults({
    required String currentPlayerId,
    required int taskMultiplier,
    required int currentRound,
  }) async {
    if (_isProcessing || _hasProcessed) return;
    _hasProcessed = true;
    setState(() => _isProcessing = true);

    try {
      final earned = await ref
          .read(voteControllerProvider.notifier)
          .calculateAndApplyScore(
            gameId: widget.gameId,
            taskMultiplier: taskMultiplier,
          );

      final room = ref.read(watchRoomProvider(widget.roomCode)).value;
      final endConditionType =
          room?.endConditionType ?? EndConditionType.rounds;
      final endConditionValue = room?.endConditionValue ?? 10;

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
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
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
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final activePlayers = playersAsync.value ?? [];
        final performer = activePlayers
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final performerName = performer?.name ?? 'Aktör';

        // Game durumu listener'ı (Riverpod bunu otomatik yönetir, koşulsuz çağrılmalı)
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

        final activePlayerIds = activePlayers.map((p) => p.id).toList();
        final allVoted =
            votesAsync.value != null &&
            activePlayerIds.every(
              (id) =>
                  id == game.currentPlayerId ||
                  votesAsync.value!.containsKey(id),
            );
        final isMyTurn = game.currentPlayerId == user?.uid;

        if (allVoted && !_isProcessing && !_hasProcessed && isMyTurn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isProcessing && !_hasProcessed) {
              _processResults(
                currentPlayerId: game.currentPlayerId,
                taskMultiplier: game.currentTask?.multiplier ?? 1,
                currentRound: game.currentRound,
              );
            }
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'ELEŞTİRİ & ALKIŞ',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
                letterSpacing: 2,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: LeaveRoomButton(roomCode: widget.roomCode),
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
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  PlayerAvatar(
                    uid: game.currentPlayerId,
                    displayName: performerName,
                    radius: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    performerName.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  // Ünvan gösterimi
                  Builder(
                    builder: (context) {
                      final profile = ref
                          .watch(watchUserProfileProvider(game.currentPlayerId))
                          .value;
                      if (profile?.activeTitle == null) {
                        return const SizedBox.shrink();
                      }
                      final cosmetics =
                          ref.watch(fetchCosmeticsProvider).value ?? [];
                      final titleItem = cosmetics
                          .where((c) => c.id == profile!.activeTitle)
                          .firstOrNull;
                      if (titleItem == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${titleItem.imageUrl} ${titleItem.name}',
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'performansını sergiledi:',
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.white54,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '"${game.currentTask?.content ?? ""}"',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  if (_isProcessing || _hasProcessed)
                    _buildProcessingIndicator()
                  else if (isMyTurn)
                    _buildWaitingForOthers()
                  else if (_hasVoted)
                    _buildVotedStatus()
                  else
                    VotingPanel(
                      onVote: (value) {
                        if (user == null) return;
                        setState(() => _hasVoted = true);
                        ref
                            .read(voteControllerProvider.notifier)
                            .castVote(
                              gameId: widget.gameId,
                              voterId: user.uid,
                              value: VoteValue.values.byName(value),
                            );
                      },
                    ),
                  const SizedBox(height: 48),
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

  Widget _buildProcessingIndicator() {
    return Column(
      children: [
        const CircularProgressIndicator(color: AppColors.accent),
        const SizedBox(height: 16),
        Text(
          'Alkışlar sayılıyor...',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.accent,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingForOthers() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        'Diğer aktörlerin değerlendirmesi bekleniyor...',
        style: GoogleFonts.libreBaskerville(
          color: Colors.white38,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVotedStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            'DEĞERLENDİRİLDİ',
            style: GoogleFonts.playfairDisplay(
              color: Colors.green,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
