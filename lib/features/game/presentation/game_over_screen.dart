import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/utils/error_message_utils.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../../shared/widgets/score/leaderboard_tile.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/game_end_utils.dart';
import '../../room/providers/room_provider.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  static const List<int> _rankRewards = [200, 100, 50];
  static const int _defaultReward = 20;

  static int rewardForRank(int rank, int totalPlayers) {
    if (rank <= _rankRewards.length) return _rankRewards[rank - 1];
    return _defaultReward;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(audioServiceProvider).playSfx(AppSfx.gameOverFanfare);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: playersAsync.when(
        data: (players) {
          final sorted = List.of(players)
            ..sort(GameEndUtils.comparePlayersForFinalRanking);
          final winner = sorted.isNotEmpty ? sorted.first : null;

          final myPlayer = user != null
              ? sorted.where((p) => p.id == user.uid).firstOrNull
              : null;
          final myRank = user != null
              ? sorted.indexWhere((p) => p.id == user.uid) + 1
              : 0;
          final hasNegativeScore = myPlayer != null && myPlayer.score <= 0;
          final myReward = (myRank > 0 && !hasNegativeScore)
              ? rewardForRank(myRank, sorted.length)
              : 0;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = _GameOverLayoutMetrics.from(constraints);

                return ResponsiveWrapper(
                  maxWidth: 720,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: SizedBox(
                      width: layout.contentWidth,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layout.screenPadding,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: layout.topGap),
                            Align(
                              alignment: Alignment.topCenter,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: layout.trophyFontSize),
                                    SizedBox(height: layout.winnerGap),
                                    Text(
                                      AppLocalizations.of(context)!.winnerCapital,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: layout.winnerLetterSpacing,
                                        fontSize: layout.winnerLabelFontSize,
                                      ),
                                    ),
                                    SizedBox(height: layout.winnerNameGap),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        winner?.name.toUpperCase() ?? '',
                                        style: AppTextStyles.headlineMedium.copyWith(
                                          color: Colors.white,
                                          letterSpacing: 2,
                                          fontSize: layout.winnerNameFontSize,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: layout.winnerScoreGap),
                                    Text(
                                      '${winner?.score ?? 0} ${AppLocalizations.of(context)!.pointsCapital}',
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: layout.winnerScoreFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: layout.sectionGap),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: layout.listHeaderPadding,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.leaderboard_rounded,
                                    color: Colors.white24,
                                    size: layout.listHeaderIconSize,
                                  ),
                                  SizedBox(width: layout.listHeaderIconGap),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!.playerRanking,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white54,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                        fontSize: layout.listHeaderFontSize,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: layout.listGap),
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.symmetric(
                                  horizontal: layout.listPadding,
                                ),
                                itemCount: sorted.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: layout.tileGap),
                                itemBuilder: (context, index) {
                                  final p = sorted[index];
                                  return LeaderboardTile(
                                    rank: index + 1,
                                    playerName: p.name,
                                    score: p.score,
                                    isCurrentPlayer: p.id == user?.uid,
                                    compact: layout.compactTiles,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                layout.bottomPanelPadding,
                                layout.bottomPanelTopGap,
                                layout.bottomPanelPadding,
                                layout.bottomPanelBottomGap,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(layout.rewardPanelPadding),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.accent.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          hasNegativeScore
                                              ? Icons.sentiment_very_dissatisfied_rounded
                                              : Icons.stars_rounded,
                                          color: hasNegativeScore
                                              ? AppColors.primary
                                              : AppColors.accent,
                                          size: layout.rewardIconSize,
                                        ),
                                        SizedBox(width: layout.rewardIconGap),
                                        Flexible(
                                          child: Text(
                                            hasNegativeScore
                                                ? AppLocalizations.of(context)!.negativeScoreMessage
                                                : AppLocalizations.of(context)!.pointsAddedToBalance(myReward),
                                            style: AppTextStyles.titleMedium.copyWith(
                                              color: hasNegativeScore
                                                  ? Colors.white70
                                                  : Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: layout.rewardTextFontSize,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: layout.actionGap),
                                  StageButton(
                                    label: AppLocalizations.of(context)!.returnToLobby,
                                    icon: Icons.home_rounded,
                                    backgroundColor: AppColors.surface,
                                    textColor: Colors.white,
                                    borderColor: AppColors.accent.withValues(
                                      alpha: 0.3,
                                    ),
                                    onPressed: () => context.go('/home'),
                                    compact: layout.compactTiles,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => TheaterLoadingScreen(
          message: AppLocalizations.of(context)!.partyOver,
        ),
        error: (e, _) {
          final l = AppLocalizations.of(context)!;
          return Center(
            child: AsyncErrorView(
              message: l.loadFailed,
              detail: ErrorMessageUtils.formatUserError(e, l),
              secondaryLabel: l.goHome,
              onRetry: () => ref.invalidate(watchPlayersProvider(widget.roomCode)),
              onSecondary: () => context.go('/home'),
            ),
          );
        },
      ),
    );
  }
}

class _GameOverLayoutMetrics {
  const _GameOverLayoutMetrics({
    required this.contentWidth,
    required this.screenPadding,
    required this.topGap,
    required this.trophyFontSize,
    required this.winnerGap,
    required this.winnerLetterSpacing,
    required this.winnerLabelFontSize,
    required this.winnerNameGap,
    required this.winnerNameFontSize,
    required this.winnerScoreGap,
    required this.winnerScoreFontSize,
    required this.sectionGap,
    required this.listHeaderPadding,
    required this.listHeaderIconSize,
    required this.listHeaderIconGap,
    required this.listHeaderFontSize,
    required this.listGap,
    required this.listPadding,
    required this.tileGap,
    required this.bottomPanelPadding,
    required this.bottomPanelTopGap,
    required this.bottomPanelBottomGap,
    required this.rewardPanelPadding,
    required this.rewardIconSize,
    required this.rewardIconGap,
    required this.rewardTextFontSize,
    required this.actionGap,
    required this.compactTiles,
  });

  final double contentWidth;
  final double screenPadding;
  final double topGap;
  final double trophyFontSize;
  final double winnerGap;
  final double winnerLetterSpacing;
  final double winnerLabelFontSize;
  final double winnerNameGap;
  final double winnerNameFontSize;
  final double winnerScoreGap;
  final double winnerScoreFontSize;
  final double sectionGap;
  final double listHeaderPadding;
  final double listHeaderIconSize;
  final double listHeaderIconGap;
  final double listHeaderFontSize;
  final double listGap;
  final double listPadding;
  final double tileGap;
  final double bottomPanelPadding;
  final double bottomPanelTopGap;
  final double bottomPanelBottomGap;
  final double rewardPanelPadding;
  final double rewardIconSize;
  final double rewardIconGap;
  final double rewardTextFontSize;
  final double actionGap;
  final bool compactTiles;

  factory _GameOverLayoutMetrics.from(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final compact = width < 390 || height < 760;

    return _GameOverLayoutMetrics(
      contentWidth: min(max(width * 0.9, 320.0), 620.0),
      screenPadding: compact ? 12 : 20,
      topGap: compact ? 10 : 20,
      trophyFontSize: compact ? 54 : 72,
      winnerGap: compact ? 8 : 16,
      winnerLetterSpacing: compact ? 2.5 : 4,
      winnerLabelFontSize: compact ? 11 : 12,
      winnerNameGap: compact ? 6 : 8,
      winnerNameFontSize: compact ? 26 : 32,
      winnerScoreGap: compact ? 6 : 8,
      winnerScoreFontSize: compact ? 20 : 24,
      sectionGap: compact ? 22 : 36,
      listHeaderPadding: compact ? 8 : 12,
      listHeaderIconSize: compact ? 16 : 18,
      listHeaderIconGap: compact ? 6 : 8,
      listHeaderFontSize: compact ? 10 : 11,
      listGap: compact ? 8 : 12,
      listPadding: compact ? 8 : 12,
      tileGap: compact ? 8 : 10,
      bottomPanelPadding: compact ? 8 : 12,
      bottomPanelTopGap: compact ? 8 : 10,
      bottomPanelBottomGap: compact ? 18 : 28,
      rewardPanelPadding: compact ? 12 : 16,
      rewardIconSize: compact ? 18 : 20,
      rewardIconGap: compact ? 10 : 12,
      rewardTextFontSize: compact ? 15 : 16,
      actionGap: compact ? 12 : 16,
      compactTiles: compact,
    );
  }
}

