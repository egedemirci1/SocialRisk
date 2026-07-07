part of 'round_result_screen.dart';

extension _RoundResultScreenBuilders on _RoundResultScreenState {
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
        final myUid = ref.watch(currentUserProvider)?.uid;
        final isHost = room?.hostId == myUid;
        final isRoomPlayer = room?.players.any((p) => p.id == myUid) ?? false;
        final canAdvanceRound = isRoomPlayer;
        final canEndGame = isHost;

        if (!isGameOver && canAdvanceRound) {
          return StageButton(
            label: AppLocalizations.of(context)!.nextTask,
            icon: Icons.arrow_forward_rounded,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.accent.withValues(alpha: 0.3),
            onPressed: () async {
              await ref.read(gameControllerProvider.notifier).nextTurn(widget.gameId);
            },
            compact: metrics.isCompact,
          );
        }

        if (isGameOver && canEndGame) {
          return StageButton(
            label: AppLocalizations.of(context)!.partyOver,
            icon: Icons.emoji_events_rounded,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.accent.withValues(alpha: 0.3),
            onPressed: () async {
              await ref.read(gameControllerProvider.notifier).endGame(widget.gameId);
            },
            compact: metrics.isCompact,
          );
        }

        return Column(
          children: [
            const AppLoadingIndicator(),
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