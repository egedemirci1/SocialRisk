part of 'difficulty_choice_screen.dart';

extension _DifficultyChoiceScreenBuilders on _DifficultyChoiceScreenState {
  Widget _buildChooserLayout(GameEntity game, _DifficultyLayoutMetrics layout) {
    return Column(
      children: [
        SizedBox(
          height: layout.heroHeight,
          child: _buildHeroCard(layout: layout),
        ),
        SizedBox(height: layout.cardGap),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _buildDifficultyCard(
                  title: AppLocalizations.of(context)!.easyCapital,
                  multiplier: '1x',
                  estimatedPoints: game.mode == GameMode.economy &&
                          game.selectedCategory != null
                      ? GameConstants.economyResolvedStoredBaseValue(
                              category: game.selectedCategory!,
                              storedValues: game.categoryMarketValues,
                            ) *
                          1
                      : 10,
                  color: Colors.green,
                  onTap: () => _selectDifficulty('easy'),
                  layout: layout,
                ),
              ),
              SizedBox(height: layout.cardGap),
              Expanded(
                child: _buildDifficultyCard(
                  title: AppLocalizations.of(context)!.mediumCapital,
                  multiplier: '2x',
                  estimatedPoints: game.mode == GameMode.economy &&
                          game.selectedCategory != null
                      ? GameConstants.economyResolvedStoredBaseValue(
                              category: game.selectedCategory!,
                              storedValues: game.categoryMarketValues,
                            ) *
                          2
                      : 20,
                  color: Colors.orange,
                  onTap: () => _selectDifficulty('medium'),
                  layout: layout,
                ),
              ),
              SizedBox(height: layout.cardGap),
              Expanded(
                child: _buildDifficultyCard(
                  title: AppLocalizations.of(context)!.hardCapital,
                  multiplier: '3x',
                  estimatedPoints: game.mode == GameMode.economy &&
                          game.selectedCategory != null
                      ? GameConstants.economyResolvedStoredBaseValue(
                              category: game.selectedCategory!,
                              storedValues: game.categoryMarketValues,
                            ) *
                          3
                      : 30,
                  color: AppColors.primary,
                  onTap: () => _selectDifficulty('hard'),
                  layout: layout,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: layout.bottomGap),
      ],
    );
  }

  Widget _buildWaitingLayout(
    String playerName,
    _DifficultyLayoutMetrics layout,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: layout.contentWidth),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(layout.cardRadius),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: layout.heroHeaderPadding),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(layout.cardRadius),
                    topRight: Radius.circular(layout.cardRadius),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.waitingCapital,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.accent,
                      letterSpacing: layout.heroLetterSpacing,
                      fontWeight: FontWeight.w900,
                      fontSize: layout.heroHeaderFontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.heroHorizontalPadding,
                  vertical: layout.waitingVerticalPadding,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: layout.loaderSize,
                      height: layout.loaderSize,
                      child: const AppLoadingIndicator(size: 40),
                    ),
                    SizedBox(height: layout.waitingGap),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppLocalizations.of(context)!.playerChoosingDifficulty(playerName),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: layout.heroTitleFontSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({required _DifficultyLayoutMetrics layout}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHero = constraints.maxHeight < 170;
        final hideSubtitle =
            layout.hideHeroSubtitle || constraints.maxHeight < 150;
        final heroScale =
            (constraints.maxHeight / max(layout.heroHeight, 1)).clamp(0.72, 1.0);
        final headerPadding = compactHero
            ? min(layout.heroHeaderPadding, 12.0) * heroScale
            : layout.heroHeaderPadding;
        final horizontalPadding = compactHero
            ? min(layout.heroHorizontalPadding, 18.0)
            : layout.heroHorizontalPadding;
        final verticalPadding = compactHero
            ? min(layout.heroVerticalPadding, 12.0) * heroScale
            : layout.heroVerticalPadding;
        final headerFont =
            max(16.0, layout.heroHeaderFontSize * heroScale);
        final titleFont = max(
          18.0,
          (compactHero ? min(layout.heroTitleFontSize, 24.0) : layout.heroTitleFontSize) *
              heroScale,
        );
        final subtitleFont = max(
          10.0,
          (compactHero ? min(layout.heroSubtitleFontSize, 12.0) : layout.heroSubtitleFontSize) *
              heroScale,
        );
        final subtitleGap = compactHero
            ? min(layout.heroSubtitleGap, 4.0) * heroScale
            : layout.heroSubtitleGap;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(layout.cardRadius),
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
                padding: EdgeInsets.symmetric(vertical: headerPadding),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(layout.cardRadius),
                    topRight: Radius.circular(layout.cardRadius),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.difficultyLevel,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.accent,
                      letterSpacing: layout.heroLetterSpacing,
                      fontWeight: FontWeight.w900,
                      fontSize: headerFont,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: LayoutBuilder(
                    builder: (context, bodyConstraints) {
                      final bodyHeight = bodyConstraints.maxHeight;
                      final hideBodySubtitle = hideSubtitle || bodyHeight < 58;
                      final oneLineSubtitle = bodyHeight < 86;
                      final subtitleBodyFont = max(
                        9.0,
                        subtitleFont *
                            (oneLineSubtitle ? 0.9 : 1.0) *
                            (bodyHeight < 76 ? 0.9 : 1.0),
                      );
                      final subtitleText = oneLineSubtitle
                          ? AppLocalizations.of(context)!.determineYourDifficultyShort
                          : AppLocalizations.of(context)!.determineYourDifficulty;
                      final bodySpacing = oneLineSubtitle
                          ? min(subtitleGap, 3.0)
                          : subtitleGap;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppLocalizations.of(context)!.riskAndReward,
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white,
                                  letterSpacing: layout.heroLetterSpacing,
                                  fontWeight: FontWeight.w900,
                                  fontSize: titleFont,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          if (!hideBodySubtitle) ...[
                            SizedBox(height: bodySpacing),
                            Flexible(
                              child: Text(
                                subtitleText,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white54,
                                  fontStyle: FontStyle.italic,
                                  fontSize: subtitleBodyFont,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: oneLineSubtitle ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDifficultyCard({
    required String title,
    required String multiplier,
    required int estimatedPoints,
    required Color color,
    required VoidCallback onTap,
    required _DifficultyLayoutMetrics layout,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(layout.difficultyCardRadius),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(layout.difficultyCardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(layout.difficultyCardRadius),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        fontSize: layout.cardTitleFontSize,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                SizedBox(width: layout.multiplierGap),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.multiplierHorizontalPadding,
                    vertical: layout.multiplierVerticalPadding,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(layout.multiplierRadius),
                  ),
                  child: Text(
                    multiplier,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: layout.multiplierFontSize,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: layout.cardSubtitleGap),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.estimatedEarningsPoint(estimatedPoints),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: layout.cardSubtitleFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}