part of 'create_room_screen.dart';

extension _CreateRoomScreenBuilders on _CreateRoomScreenState {
  Widget _buildSection({
    required _CreateRoomMetrics metrics,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(metrics.sectionPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(metrics.sectionRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: metrics.isCompactHeight ? 8 : 12,
            offset: Offset(0, metrics.isCompactHeight ? 3 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.accent, size: metrics.sectionIconSize),
              SizedBox(width: metrics.inlineGap),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: metrics.sectionTitleFontSize,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.sectionInnerGap),
          child,
        ],
      ),
    );
  }

  Widget _buildEndCondition(_CreateRoomMetrics metrics) {
    Color getSliderColor(double ratio) {
      if (ratio < 0.5) {
        return Color.lerp(
              const Color(0xFF00E5FF),
              const Color(0xFF00E676),
              ratio * 2,
            ) ??
            AppColors.accent;
      }
      return Color.lerp(
            const Color(0xFF00E676),
            const Color(0xFFD500F9),
            (ratio - 0.5) * 2,
          ) ??
          AppColors.accent;
    }

    final scoreRatio = ((_scoreTarget - 50) / 200).clamp(0.0, 1.0);
    final roundRatio = ((_roundTarget - 2) / 8).clamp(0.0, 1.0);
    final scoreColor = getSliderColor(scoreRatio);
    final roundColor = getSliderColor(roundRatio);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: AppLocalizations.of(context)!.roundLabel,
                isSelected: !_isScoreMode,
                onTap: () => _setScoreMode(false),
                compact: metrics.isCompactWidth || metrics.isCompactHeight,
              ),
            ),
            SizedBox(width: metrics.inlineGap),
            Expanded(
              child: _ToggleChip(
                label: AppLocalizations.of(context)!.pointLabel,
                isSelected: _isScoreMode,
                onTap: () => _setScoreMode(true),
                compact: metrics.isCompactWidth || metrics.isCompactHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: metrics.contentGap),
        if (_isScoreMode) ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.titleLarge.copyWith(
              fontSize:
                  metrics.valueFontBase + (metrics.valueFontDelta * scoreRatio),
              fontWeight: FontWeight.w900,
              color: scoreColor,
            ),
            child: Text('${_scoreTarget.toInt()} ${AppLocalizations.of(context)!.points}'),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: scoreColor,
              inactiveTrackColor: Colors.black38,
              thumbColor: scoreColor,
              overlayColor: scoreColor.withValues(alpha: 0.2),
              trackHeight: metrics.sliderTrackHeight,
            ),
            child: Slider(
              value: _scoreTarget,
              min: 50,
              max: 250,
              divisions: 4,
              onChanged: (value) {
                if (value != _scoreTarget) {
                  HapticFeedback.selectionClick();
                  _setScoreTarget(value);
                }
              },
            ),
          ),
          Transform.translate(
            offset: Offset(0, -metrics.sliderLabelOffset),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.sliderLabelHorizontalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '50',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white38,
                      fontSize: metrics.helperFontSize,
                    ),
                  ),
                  Text(
                    '250',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white38,
                      fontSize: metrics.helperFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.titleLarge.copyWith(
              fontSize:
                  metrics.valueFontBase + (metrics.valueFontDelta * roundRatio),
              fontWeight: FontWeight.w900,
              color: roundColor,
            ),
            child: Text('${_roundTarget.toInt()} ${AppLocalizations.of(context)!.rounds}'),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: roundColor,
              inactiveTrackColor: Colors.black38,
              thumbColor: roundColor,
              overlayColor: roundColor.withValues(alpha: 0.2),
              trackHeight: metrics.sliderTrackHeight,
            ),
            child: Slider(
              value: _roundTarget,
              min: 2,
              max: 10,
              divisions: 8,
              onChanged: (value) {
                if (value != _roundTarget) {
                  HapticFeedback.selectionClick();
                  _setRoundTarget(value);
                }
              },
            ),
          ),
          Transform.translate(
            offset: Offset(0, -metrics.sliderLabelOffset),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.sliderLabelHorizontalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '2',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white38,
                      fontSize: metrics.helperFontSize,
                    ),
                  ),
                  Text(
                    '10',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white38,
                      fontSize: metrics.helperFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGameMode(_CreateRoomMetrics metrics, bool isPremium) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                  label: AppLocalizations.of(context)!.classicWheel,
                isSelected: _selectedMode == GameMode.classic,
                compact: metrics.isCompactWidth || metrics.isCompactHeight,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _selectClassicMode();
                },
              ),
            ),
            SizedBox(width: metrics.inlineGap),
            Expanded(
              child: _ToggleChip(
                label: AppLocalizations.of(context)!.economyMode,
                isSelected: _selectedMode == GameMode.economy,
                compact: metrics.isCompactWidth || metrics.isCompactHeight,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _selectEconomyMode(isPremium);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: metrics.contentGap),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_selectedMode),
            padding: EdgeInsets.all(metrics.infoBoxPadding),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(metrics.infoBoxRadius),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _selectedMode == GameMode.classic
                      ? Icons.info_outline_rounded
                      : Icons.monetization_on_outlined,
                  color: AppColors.accent,
                  size: metrics.infoIconSize,
                ),
                SizedBox(width: metrics.contentGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMode == GameMode.classic
                            ? AppLocalizations.of(context)!.classicModeTitle
                            : AppLocalizations.of(context)!.economyModeTitle,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: metrics.infoTitleFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: metrics.textTightGap),
                      Text(
                        _selectedMode == GameMode.classic
                              ? AppLocalizations.of(context)!.classicModeDesc
                          : AppLocalizations.of(context)!.economyModeDesc,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: metrics.bodyFontSize,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          height: metrics.bodyLineHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(_CreateRoomMetrics metrics, bool isPremium) {
    final categories = CategoryConstants.all;
    final languageCode = LocaleProvider.of(context).languageCode;
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = metrics.chipSpacing;
        final runSpacing = metrics.chipRunSpacing;
        final minChipWidth = metrics.minCategoryChipWidth;
        final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
        final crossCount =
            (maxWidth / (minChipWidth + spacing)).floor().clamp(2, 10);
        final itemWidth = (maxWidth - (crossCount - 1) * spacing) / crossCount;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: categories.map((categoryDef) {
            final categoryId = categoryDef.id;
            final isSelected = _selectedCategories.contains(categoryId);
            return SizedBox(
              width: itemWidth,
              child: GestureDetector(
                onTap: () => _onCategoryTap(categoryId, isPremium, isSelected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.categoryChipHorizontalPadding,
                    vertical: metrics.categoryChipVerticalPadding,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.3)
                          : Colors.white10,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (categoryId == CategoryConstants.customCategoryId && !isPremium) ...[
                          Icon(
                            Icons.lock_outline_rounded,
                            size: metrics.categoryFontSize,
                            color: Colors.white24,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            categoryDef.localizedName(languageCode),
                            style: AppTextStyles.titleSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (categoryId == CategoryConstants.customCategoryId && !isPremium)
                                      ? Colors.white24
                                      : Colors.white54,
                              fontSize: metrics.categoryFontSize,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}