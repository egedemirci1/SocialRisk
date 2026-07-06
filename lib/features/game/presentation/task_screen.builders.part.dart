part of 'task_screen.dart';

extension _TaskScreenBuilders on _TaskScreenState {
  Widget _buildTopTitleCard({
    required String badge,
    required String title,
    required _TaskLayoutMetrics layout,
    String? subtitle,
    bool showSubtitle = true,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        layout.titleCardHorizontalPadding,
        layout.titleCardVerticalPadding,
        layout.titleCardHorizontalPadding,
        layout.titleCardBottomPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.96),
            AppColors.surface.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(layout.titleCardRadius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: layout.badgeHorizontalPadding,
              vertical: layout.badgeVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              badge,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                fontSize: layout.badgeFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: layout.titleGap),
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: layout.titleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null && showSubtitle) ...[
            SizedBox(height: layout.subtitleGap),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white54,
                fontSize: layout.subtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWheelView({
    required bool isMyTurn,
    required String playerName,
    required dynamic currentPlayer,
    required List<String> categories,
    required _TaskLayoutMetrics layout,
    required double contentWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final screenHeight = MediaQuery.sizeOf(context).height;
        final isVeryShort = screenHeight <= 686 || availableHeight < 610;
        final isDense = isVeryShort || availableHeight < 650;
        final topGap = isVeryShort
            ? 2.0
            : max(4.0, availableHeight * 0.012);
        final sectionGap = isVeryShort
            ? 4.0
            : max(6.0, availableHeight * 0.014);
        final wheelGap = isVeryShort
            ? 6.0
            : max(8.0, availableHeight * 0.018);
        final bottomGap = isVeryShort
            ? 0.0
            : max(2.0, availableHeight * 0.006);
        final contentHeight =
            max(0.0, availableHeight - topGap - sectionGap - wheelGap - bottomGap);
        final playerHeight =
            currentPlayer != null ? contentHeight * (isVeryShort ? 0.21 : 0.25) : 0.0;
        final titleHeight = contentHeight * (isVeryShort ? 0.18 : 0.23);
        final wheelHeight = max(0.0, contentHeight - playerHeight - titleHeight);
        final wheelSize = min(
          layout.wheelSize,
          max(isVeryShort ? 100.0 : 160.0, wheelHeight * (isDense ? 0.76 : 0.8)),
        );

        return Column(
          children: [
            SizedBox(height: topGap),
            if (currentPlayer != null)
              SizedBox(
                height: playerHeight,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: contentWidth * (isVeryShort ? 0.56 : 0.62),
                      child: PlayerSpotlight(
                        player: currentPlayer,
                        isMe: isMyTurn,
                        compact: layout.isCompact || isDense,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: sectionGap),
            SizedBox(
              height: titleHeight,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: contentWidth,
                    child: _buildTopTitleCard(
                      badge: AppLocalizations.of(context)!.partyStarting.toUpperCase(),
                                  title: AppLocalizations.of(context)!.determineYourTask,
                                  subtitle: AppLocalizations.of(context)!.spinWheelSubtitle,
                      showSubtitle: !isVeryShort,
                      layout: layout,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: wheelGap),
            SizedBox(
              height: wheelHeight,
              child: Align(
                alignment: Alignment.topCenter,
                child: SpinWheel(
                  spinningTarget: ref
                      .watch(watchGameProvider(widget.gameId))
                      .value
                      ?.spinningTarget,
                  canSpin: isMyTurn,
                  playerName: playerName,
                  categories: categories,
                  compact: layout.isCompact || isDense,
                  maxWheelSize: wheelSize,
                  onSpinRequest: () {
                    if (categories.isEmpty) return;
                    // Web: ses jest zincirinde kalmalı; Firestore dönüşünde çalınca engellenir.
                    ref.read(audioServiceProvider).playSfx(AppSfx.wheelSpinStart);
                    final randomCat = categories[_random.nextInt(categories.length)];
                    ref.read(gameControllerProvider.notifier).setSpinningTarget(
                          gameId: widget.gameId,
                          target: randomCat,
                        );
                  },
                  onSpinComplete: _onWheelResult,
                ),
              ),
            ),
            SizedBox(height: bottomGap),
          ],
        );
      },
    );
  }

  Widget _buildEconomyRedirect({
    required GameEntity game,
    required List<String> categories,
    required bool isMyTurn,
    required String? myUserId,
  }) {
    final isSingleCategory = categories.length == 1;

    if (isSingleCategory) {
      if (_autoPickFailed) {
        return Center(
          child: AsyncErrorView(
            message: AppLocalizations.of(context)!.autoPickFailed,
            onRetry: () {
              _setAutoPickFailed(false);
            },
          ),
        );
      }

      final selectedCategory = categories.first;
      final canAutoPick =
          isMyTurn &&
          myUserId != null &&
          !_isAutoPickingSingleCategory &&
          !_autoPickFailed &&
          game.currentTask == null &&
          game.selectedCategory == null &&
          game.status == GameStatus.playing;

      if (canAutoPick) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted || _isAutoPickingSingleCategory) return;
          _setAutoPickingSingleCategory(true);
          try {
            await ref.read(gameControllerProvider.notifier).pickCategoryEconomy(
                  gameId: widget.gameId,
                  playerId: myUserId,
                  category: selectedCategory,
                );
          } catch (_) {
            if (mounted) _setAutoPickFailed(true);
          } finally {
            if (mounted) {
              _setAutoPickingSingleCategory(false);
            }
          }
        });
      }

      return const AppLoadingIndicator();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.replace(
        '/economy-pick',
        extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
      );
    });
    return const AppLoadingIndicator();
  }

}