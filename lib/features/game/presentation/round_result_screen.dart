import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:social_risk/l10n/app_localizations.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/buttons/leave_room_button.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/social_risk_logo.dart';
import '../../admin/providers/task_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';

class RoundResultScreen extends ConsumerStatefulWidget {
  const RoundResultScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<RoundResultScreen> createState() => _RoundResultScreenState();
}

class _RoundResultScreenState extends ConsumerState<RoundResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _voteOutcomeSfxPlayed = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    Future.microtask(() {
      if (!mounted) return;
      ref.read(audioServiceProvider).playSfx(AppSfx.gameOver);
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  /// `lastRoundMood`: dislike → failed; like / neutral → success (aynı dosya).
  void _tryPlayVoteOutcomeSfx(GameEntity game) {
    if (_voteOutcomeSfxPlayed) return;
    final mood = game.lastRoundMood;
    if (mood == null) return;
    _voteOutcomeSfxPlayed = true;
    final audio = ref.read(audioServiceProvider);
    if (mood == 'dislike') {
      audio.playSfx(AppSfx.voteResultDislike);
    } else {
      audio.playSfx(AppSfx.voteResultLike);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final metrics = _RoundResultMetrics.from(context);
    final currentUser = ref.watch(currentUserProvider);

    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      if (!context.mounted) return;
      next.whenData((game) {
        if (game != null) {
          _tryPlayVoteOutcomeSfx(game);
        }
      });

      final prevStatus = previous?.value?.status;
      final currentStatus = next.value?.status;

      if (currentStatus == GameStatus.playing ||
          currentStatus == GameStatus.choosingDifficulty) {
        context.go(
          '/task',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
      } else if (currentStatus == GameStatus.finished &&
          prevStatus != GameStatus.finished) {
        context.go('/game-over', extra: widget.roomCode);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: LeaveRoomButton(roomCode: widget.roomCode),
      ),
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return const Center(child: CircularProgressIndicator());
          }

          _tryPlayVoteOutcomeSfx(game);

          final earnedScore = game.lastRoundScore ?? 0;
          final audienceScore = game.lastRoundAudienceScore ?? 0;
          final multiplier = game.lastRoundMultiplier ?? 1;
          final isPass = multiplier == 0;
          final isGameOver = game.status == GameStatus.finished;
          final players = playersAsync.value ?? [];
          final currentPlayer = players
              .where((p) => p.id == (game.lastRoundPlayerId ?? game.currentPlayerId))
              .firstOrNull;
          final playerName = currentPlayer?.name ?? AppLocalizations.of(context)!.playerDefaultName;

          return SafeArea(
            child: ResponsiveWrapper(
              padding: EdgeInsets.symmetric(horizontal: metrics.screenPadding),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildResultHeader(game, earnedScore, isPass, playerName, metrics),
                    SizedBox(height: metrics.sectionGap),
                    _buildScoreCard(audienceScore, earnedScore, multiplier, isPass, game.lastRoundMood, metrics),
                    SizedBox(height: metrics.sectionGap),
                    _buildLeaderboard(players, game, metrics, currentUser?.uid),
                    SizedBox(height: metrics.sectionGap),
                    if (game.currentTask != null)
                      _TaskFeedbackSection(
                        taskId: game.currentTask!.id,
                        taskContent: game.currentTask!.content,
                        compact: metrics.isCompact,
                      ),
                    SizedBox(height: metrics.bottomGap),
                    _buildActionButtons(isGameOver, game, metrics),
                    SizedBox(height: metrics.isCompact ? 16 : 32),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.error(e.toString()))),
      ),
      floatingActionButton: _buildConfetti(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildResultHeader(
    GameEntity game,
    int score,
    bool isPass,
    String playerName,
    _RoundResultMetrics metrics,
  ) {
    return Transform.translate(
      offset: const Offset(0, -30), // Pull the whole block up over the safe area padding
      child: Column(
        children: [
          SocialRiskLogo(
            height: metrics.isCompact ? 56 : 72,
          ),
          SizedBox(height: metrics.textGap * 2),
        Text(
                  isPass ? AppLocalizations.of(context)!.taskRejected : AppLocalizations.of(context)!.roundOver,
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            letterSpacing: 2,
            fontSize: metrics.headerTitleSize,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: metrics.smallGap),
        Text(
          isPass
              ? AppLocalizations.of(context)!.playerRefusedRole(playerName)
              : AppLocalizations.of(context)!.playerCompletedPerformance(playerName),
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white54,
            fontSize: metrics.bodyFontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
      ),
    );
  }

  Widget _buildScoreCard(
    int audienceScore,
    int score,
    int multiplier,
    bool isPass,
    String? mood,
    _RoundResultMetrics metrics,
  ) {
    return Container(
      padding: EdgeInsets.all(metrics.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          if (!isPass) ...[
            _ScoreRow(
              label: AppLocalizations.of(context)!.audienceScore,
              value: '$audienceScore',
              color: audienceScore >= 0 ? Colors.green : AppColors.primary,
              compact: metrics.isCompact,
            ),
            Divider(color: Colors.white10, height: metrics.dividerHeight),
            _ScoreRow(
              label: AppLocalizations.of(context)!.difficultyMultiplier,
              value: 'x$multiplier',
              color: Colors.white,
              compact: metrics.isCompact,
            ),
            Divider(color: Colors.white10, height: metrics.dividerHeight),
            _ScoreRow(
              label: AppLocalizations.of(context)!.performanceResult,
              value: mood == 'like'
                  ? AppLocalizations.of(context)!.likedResult
                  : (mood == 'dislike' ? AppLocalizations.of(context)!.dislikedResult : AppLocalizations.of(context)!.neutralResult),
              color: mood == 'like'
                  ? Colors.green
                  : (mood == 'dislike' ? Colors.red : Colors.orange),
              compact: metrics.isCompact,
            ),
            Divider(color: Colors.white10, height: metrics.dividerHeight),
          ],
          _ScoreRow(
            label: score >= 0 ? AppLocalizations.of(context)!.gainedPoints : AppLocalizations.of(context)!.lostPoints,
            value: '$score',
            color: AppColors.accent,
            isBold: true,
            compact: metrics.isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(
    List<dynamic> players,
    GameEntity game,
    _RoundResultMetrics metrics,
    String? myUid,
  ) {
    final sortedPlayers = List.of(players)
      ..sort((a, b) => b.score.compareTo(a.score));
    return Container(
      padding: EdgeInsets.all(metrics.listPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.playerRanking,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: metrics.labelFontSize,
            ),
          ),
          SizedBox(height: metrics.textGap),
          ...List.generate(sortedPlayers.length, (index) {
            final p = sortedPlayers[index];
            final isMe = p.id == myUid;
            return _LeaderboardTile(
              player: p,
              rank: index + 1,
              isTarget: isMe,
              compact: metrics.isCompact,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    bool isGameOver,
    GameEntity game,
    _RoundResultMetrics metrics,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final room = ref.watch(watchRoomProvider(widget.roomCode)).value;
        final isHost = room?.hostId == ref.watch(currentUserProvider)?.uid;

        if (isHost) {
          return StageButton(
                label: isGameOver ? AppLocalizations.of(context)!.partyOver : AppLocalizations.of(context)!.nextTask,
            icon: isGameOver
                ? Icons.emoji_events_rounded
                : Icons.arrow_forward_rounded,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.accent.withValues(alpha: 0.3),
            onPressed: () async {
              if (isGameOver) {
                await ref.read(gameControllerProvider.notifier).endGame(widget.gameId);
              } else {
                await ref.read(gameControllerProvider.notifier).nextTurn(widget.gameId);
              }
            },
            compact: metrics.isCompact,
          );
        }

        return Column(
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: metrics.textGap),
            Text(
              isGameOver
                  ? AppLocalizations.of(context)!.waitingForFinal
                  : AppLocalizations.of(context)!.waitingForHostNextRound,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white30,
                fontStyle: FontStyle.italic,
                fontSize: metrics.bodyFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget? _buildConfetti() {
    final score = ref.watch(watchGameProvider(widget.gameId)).value?.lastRoundScore ?? 0;
    if (score <= 0) return null;
    return IgnorePointer(
      child: Lottie.asset(
        'assets/lotties/confetti.json',
        controller: _lottieController,
        onLoaded: (comp) {
          _lottieController.duration = comp.duration;
          _lottieController.forward(from: 0.0);
        },
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool compact;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 13 : 16,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontSize: compact ? 16 : 18,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends ConsumerWidget {
  const _LeaderboardTile({
    required this.player,
    required this.rank,
    required this.isTarget,
    required this.compact,
  });

  final dynamic player;
  final int rank;
  final bool isTarget;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(watchUserProfileProvider(player.id)).value;
    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];
    final titleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 6 : 8),
      padding: EdgeInsets.all(compact ? 6 : 8),
      decoration: BoxDecoration(
        color: isTarget ? AppColors.accent.withValues(alpha: 0.05) : Colors.black12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTarget
              ? AppColors.accent.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Rank badge — fixed minimum width so '#' and number never wrap
          Container(
            constraints: const BoxConstraints(minWidth: 44),
            child: Text(
              '#$rank',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 10 : 12,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          PlayerAvatar(uid: player.id, displayName: player.name, radius: compact ? 13 : 15),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 12 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (titleItem != null)
                  Text(
                    '${titleItem.imageUrl} ${titleItem.name}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 9 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '${player.score}',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFeedbackSection extends ConsumerStatefulWidget {
  const _TaskFeedbackSection({
    required this.taskId,
    required this.taskContent,
    required this.compact,
  });

  final String taskId;
  final String taskContent;
  final bool compact;

  @override
  ConsumerState<_TaskFeedbackSection> createState() => _TaskFeedbackSectionState();
}

class _TaskFeedbackSectionState extends ConsumerState<_TaskFeedbackSection> {
  bool? _givenFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.evaluateScenario,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: widget.compact ? 10 : 12,
            ),
          ),
          SizedBox(height: widget.compact ? 10 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FeedbackButton(
                icon: Icons.thumb_up_rounded,
                label: AppLocalizations.of(context)!.goodUpper,
                isActive: _givenFeedback == true,
                color: Colors.green,
                onTap: () => _submit(true),
                compact: widget.compact,
              ),
              SizedBox(width: widget.compact ? 10 : 12),
              _FeedbackButton(
                icon: Icons.thumb_down_rounded,
                label: AppLocalizations.of(context)!.badUpper,
                isActive: _givenFeedback == false,
                color: AppColors.primary,
                onTap: () => _submit(false),
                compact: widget.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit(bool like) {
    if (_givenFeedback != null) return;
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId == null) return;
    setState(() => _givenFeedback = like);
    ref.read(taskControllerProvider.notifier).submitFeedback(
          taskId: widget.taskId,
          userId: userId,
          isLike: like,
        );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? color : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? color : Colors.white38, size: compact ? 14 : 16),
            SizedBox(width: compact ? 6 : 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? color : Colors.white38,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundResultMetrics {
  const _RoundResultMetrics({
    required this.isCompact,
    required this.isTiny,
    required this.screenPadding,
    required this.contentWidth,
    required this.sectionGap,
    required this.bottomGap,
    required this.cardPadding,
    required this.listPadding,
    required this.cardRadius,
    required this.headerIconSize,
    required this.headerEmojiSize,
    required this.headerTitleSize,
    required this.bodyFontSize,
    required this.labelFontSize,
    required this.textGap,
    required this.smallGap,
    required this.dividerHeight,
  });

  final bool isCompact;
  final bool isTiny;
  final double screenPadding;
  final double contentWidth;
  final double sectionGap;
  final double bottomGap;
  final double cardPadding;
  final double listPadding;
  final double cardRadius;
  final double headerIconSize;
  final double headerEmojiSize;
  final double headerTitleSize;
  final double bodyFontSize;
  final double labelFontSize;
  final double textGap;
  final double smallGap;
  final double dividerHeight;

  factory _RoundResultMetrics.from(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // iPhone SE = 375x667. Trigger compact much earlier.
    final isCompact = size.width < 400 || size.height < 700;
    // Super compact for truly tiny screens
    final isTiny = size.height < 680;

    return _RoundResultMetrics(
      isCompact: isCompact,
      isTiny: isTiny,
      screenPadding: isCompact ? 12 : 24,
      contentWidth: isCompact ? size.width - 24 : 380,
      sectionGap: isTiny ? 8 : (isCompact ? 10 : 20),
      bottomGap: isTiny ? 10 : (isCompact ? 14 : 28),
      cardPadding: isTiny ? 10 : (isCompact ? 12 : 20),
      listPadding: isTiny ? 8 : (isCompact ? 10 : 14),
      cardRadius: isCompact ? 8 : 12,
      headerIconSize: isTiny ? 40 : (isCompact ? 52 : 72),
      headerEmojiSize: isCompact ? 24 : 40,
      headerTitleSize: isTiny ? 16 : (isCompact ? 18 : 24),
      bodyFontSize: isTiny ? 11 : (isCompact ? 12 : 14),
      labelFontSize: isTiny ? 9 : (isCompact ? 10 : 12),
      textGap: isTiny ? 6 : (isCompact ? 8 : 14),
      smallGap: isTiny ? 3 : (isCompact ? 4 : 8),
      dividerHeight: isTiny ? 14 : (isCompact ? 16 : 22),
    );
  }
}
