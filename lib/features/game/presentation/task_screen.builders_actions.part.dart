part of 'task_screen.dart';

extension _TaskScreenBuildersPart2 on _TaskScreenState {
  Widget _buildTaskView({
    required GameEntity game,
    required int passStreak,
    required dynamic task,
    required RoomVisibility visibility,
    required bool isMyTurn,
    required String playerName,
    required _TaskLayoutMetrics layout,
  }) {
    final isClosed = visibility == RoomVisibility.closed && !_contentRevealed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewHeight = constraints.maxHeight;
        final topGap = max(4.0, viewHeight * 0.01);
        final headerHeight = layout.isCompact ? 54.0 : 62.0;
        final innerGap = layout.isCompact ? 10.0 : 14.0;
        final actionHeight = isClosed && isMyTurn
            ? (layout.isCompact ? 54.0 : 60.0)
            : (isMyTurn ? (layout.isCompact ? 110.0 : 124.0) : 26.0);
        final contentHeight = max(
          0.0,
          viewHeight -
              topGap -
              headerHeight -
              (layout.taskCardPadding * 2) -
              actionHeight -
              (innerGap * 4),
        );
        final categoryHeight = layout.isCompact ? 34.0 : 38.0;
        final titleHeight = max(74.0, contentHeight * 0.2);
        final cardHeight = max(
          150.0,
          contentHeight - categoryHeight - titleHeight,
        );

        final int cardPoints = game.mode == GameMode.economy
            ? ((GameConstants.economyResolvedStoredBaseValue(
                          category: task.category,
                          storedValues: game.categoryMarketValues,
                        ) *
                        task.multiplier)
                    .toInt())
            : (10 * task.multiplier).toInt();

        return Column(
          children: [
            SizedBox(height: topGap),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(layout.titleCardRadius),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: layout.headerVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppLocalizations.of(context)!.partyStarting.toUpperCase(),
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.accent,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(layout.taskCardPadding),
                        child: Column(
                          children: [
                            SizedBox(
                              height: categoryHeight,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: layout.categoryBadgeHorizontalPadding,
                                      vertical: layout.categoryBadgeVerticalPadding,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: AppColors.accentGradient.begin,
                                        end: AppColors.accentGradient.end,
                                        colors: AppColors.accentGradient.colors
                                            .map((c) => c.withValues(alpha: 0.15))
                                            .toList(),
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: AppColors.accent.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.categoryVariable(
                                        TaskTranslationMap.getCategoryTranslation(
                                          task.category,
                                          LocaleProvider.of(context).languageCode,
                                        ),
                                      ),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: layout.badgeFontSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: innerGap),
                            SizedBox(
                              height: titleHeight,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SizedBox(
                                    width: layout.contentWidth * 0.8,
                                    child: _buildTopTitleCard(
                           badge: isClosed ? AppLocalizations.of(context)!.hiddenRound : AppLocalizations.of(context)!.taskCapital,
                                      title: isClosed
                                  ? AppLocalizations.of(context)!.nextTaskHidden
                                          : (isMyTurn
                                      ? AppLocalizations.of(context)!.yourContentHere
                                              : AppLocalizations.of(context)!.contentForPlayer(playerName)),
                                      layout: layout,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: innerGap),
                            Expanded(
                              child: Center(
                                child: ScaleTransition(
                                  scale: _cardAnimation,
                                  child: SizedBox(
                                    height: cardHeight,
                                    child: GameCard(
                                      category: task.category,
                                      content: isClosed
                                  ? AppLocalizations.of(context)!.openCardToViewTask
                                          : TaskTranslationMap.getTranslation(
                                              task.id,
                                              task.content,
                                              LocaleProvider.of(context).languageCode,
                                            ),
                                      points: cardPoints,
                                      compact: layout.isCompact,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: innerGap),
                            SizedBox(
                              height: actionHeight,
                              child: _buildTaskActionSection(
                                isClosed: isClosed,
                                isMyTurn: isMyTurn,
                                playerName: playerName,
                                passStreak: passStreak,
                                layout: layout,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskActionSection({
    required bool isClosed,
    required bool isMyTurn,
    required String playerName,
    required int passStreak,
    required _TaskLayoutMetrics layout,
  }) {
    if (isClosed && isMyTurn) {
      return Center(
        child: StageButton(
                                label: AppLocalizations.of(context)!.openTask,
          backgroundColor: AppColors.accent,
          textColor: Colors.black,
          borderColor: AppColors.accent,
          onPressed: _revealContent,
          compact: layout.isCompact,
        ),
      );
    }

    if (isMyTurn) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StageButton(
                        label: AppLocalizations.of(context)!.startTask,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.accent,
            onPressed: _acceptTask,
            isLoading: _isAccepting,
            compact: layout.isCompact,
          ),
          SizedBox(height: layout.passButtonGap),
          _AnimatedPassButton(
            passStreak: passStreak,
            isPassing: _isPassing,
            onPass: _passTask,
            compact: layout.isCompact,
          ),
        ],
      );
    }

    return Center(
      child: Text(
        AppLocalizations.of(context)!.readingContentSubtitle(playerName),
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white30,
          fontStyle: FontStyle.italic,
          fontSize: layout.subtitleFontSize,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}