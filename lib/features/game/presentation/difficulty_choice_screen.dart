import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';

class DifficultyChoiceScreen extends ConsumerStatefulWidget {
  const DifficultyChoiceScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<DifficultyChoiceScreen> createState() =>
      _DifficultyChoiceScreenState();
}

class _DifficultyChoiceScreenState
    extends ConsumerState<DifficultyChoiceScreen> {
  bool _isLoading = false;
  bool _hasRedirected = false;

  String _toTurkishUpper(String value) {
    return value
        .replaceAll('i', 'İ')
        .replaceAll('ı', 'I')
        .replaceAll('ş', 'Ş')
        .replaceAll('ğ', 'Ğ')
        .replaceAll('ü', 'Ü')
        .replaceAll('ö', 'Ö')
        .replaceAll('ç', 'Ç')
        .toUpperCase();
  }

  Future<void> _selectDifficulty(String difficulty) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(gameControllerProvider.notifier)
          .chooseDifficulty(gameId: widget.gameId, difficulty: difficulty);
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, AppLocalizations.of(context)!.error(e.toString()));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(watchGameProvider(widget.gameId), (prev, next) {
      if (!mounted || _hasRedirected) return;
      final game = next.value;
      print('DIFFICULTY SCREEN: game status = ${game?.status}');
      if (game == null) return;
      if (game.status == GameStatus.choosingDifficulty) {
        print('DIFFICULTY SCREEN: staying on difficulty screen');
        return;
      }

      print('DIFFICULTY SCREEN: redirecting, status = ${game.status}');
      _hasRedirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (game.status == GameStatus.results) {
          context.go(
            '/round-result',
            extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
          );
        } else if (game.status == GameStatus.finished) {
          context.go('/game-over', extra: widget.roomCode);
        } else {
          print('DIFFICULTY SCREEN: going to /task, status = ${game.status}');
          context.replace(
            '/task',
            extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
          );
        }
      });
    });

    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: Text(AppLocalizations.of(context)!.gameNotFound)),
          );
        }

        final user = ref.read(currentUserProvider);
        final isMyTurn = game.currentPlayerId == user?.uid;
        final players = roomAsync.value?.players ?? [];
        final currentPlayer =
            players.where((p) => p.id == game.currentPlayerId).firstOrNull;
        final playerName = currentPlayer?.name ?? AppLocalizations.of(context)!.playerDefaultName;

        if (game.status != GameStatus.choosingDifficulty && !_hasRedirected) {
          _hasRedirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.replace(
                '/task',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
          });
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: ExitRoomButton(roomCode: widget.roomCode),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            minimum: const EdgeInsets.only(bottom: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = _DifficultyLayoutMetrics.from(constraints);

                return Center(
                  child: SizedBox(
                    width: layout.contentWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: layout.horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: layout.topGap),
                          SizedBox(
                            height: layout.categoryHeight,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: layout.categoryHorizontalPadding,
                                    vertical: layout.categoryVerticalPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                      layout.categoryRadius,
                                    ),
                                    border: Border.all(
                                      color: AppColors.accent.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    '${AppLocalizations.of(context)!.categoryVariable(game.selectedCategory != null ? _toTurkishUpper(game.selectedCategory!) : "?")}',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: layout.categoryLetterSpacing,
                                      fontSize: layout.categoryFontSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: layout.sectionGap),
                          Expanded(
                            child: isMyTurn
                                ? _buildChooserLayout(game, layout)
                                : _buildWaitingLayout(playerName, layout),
                          ),
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
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text(AppLocalizations.of(context)!.error(e.toString()))),
      ),
    );
  }

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
                      child: const CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
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
                                'RİSK VE ÖDÜL',
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

class _DifficultyLayoutMetrics {
  const _DifficultyLayoutMetrics({
    required this.contentWidth,
    required this.horizontalPadding,
    required this.topGap,
    required this.sectionGap,
    required this.bottomGap,
    required this.categoryHeight,
    required this.categoryHorizontalPadding,
    required this.categoryVerticalPadding,
    required this.categoryRadius,
    required this.categoryFontSize,
    required this.categoryLetterSpacing,
    required this.heroHeight,
    required this.cardGap,
    required this.cardRadius,
    required this.heroHeaderPadding,
    required this.heroHorizontalPadding,
    required this.heroVerticalPadding,
    required this.heroLetterSpacing,
    required this.heroHeaderFontSize,
    required this.heroTitleFontSize,
    required this.heroSubtitleFontSize,
    required this.heroSubtitleGap,
    required this.hideHeroSubtitle,
    required this.waitingVerticalPadding,
    required this.waitingGap,
    required this.loaderSize,
    required this.difficultyCardRadius,
    required this.difficultyCardPadding,
    required this.cardTitleFontSize,
    required this.cardSubtitleFontSize,
    required this.cardSubtitleGap,
    required this.multiplierGap,
    required this.multiplierHorizontalPadding,
    required this.multiplierVerticalPadding,
    required this.multiplierRadius,
    required this.multiplierFontSize,
  });

  final double contentWidth;
  final double horizontalPadding;
  final double topGap;
  final double sectionGap;
  final double bottomGap;
  final double categoryHeight;
  final double categoryHorizontalPadding;
  final double categoryVerticalPadding;
  final double categoryRadius;
  final double categoryFontSize;
  final double categoryLetterSpacing;
  final double heroHeight;
  final double cardGap;
  final double cardRadius;
  final double heroHeaderPadding;
  final double heroHorizontalPadding;
  final double heroVerticalPadding;
  final double heroLetterSpacing;
  final double heroHeaderFontSize;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroSubtitleGap;
  final bool hideHeroSubtitle;
  final double waitingVerticalPadding;
  final double waitingGap;
  final double loaderSize;
  final double difficultyCardRadius;
  final double difficultyCardPadding;
  final double cardTitleFontSize;
  final double cardSubtitleFontSize;
  final double cardSubtitleGap;
  final double multiplierGap;
  final double multiplierHorizontalPadding;
  final double multiplierVerticalPadding;
  final double multiplierRadius;
  final double multiplierFontSize;

  factory _DifficultyLayoutMetrics.from(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final short = height < 700;
    final medium = height < 820;

    return _DifficultyLayoutMetrics(
      contentWidth: min(max(width * 0.86, 320.0), width),
      horizontalPadding: width < 380 ? 12 : 20,
      topGap: short ? 8 : 20,
      sectionGap: short ? 10 : 24,
      bottomGap: short ? 10 : 18,
      categoryHeight: short ? 52 : 66,
      categoryHorizontalPadding: short ? 16 : 22,
      categoryVerticalPadding: short ? 10 : 12,
      categoryRadius: short ? 20 : 24,
      categoryFontSize: short ? 17 : 20,
      categoryLetterSpacing: short ? 1.2 : 2,
      heroHeight: short ? height * 0.20 : height * 0.24,
      cardGap: short ? 8 : 16,
      cardRadius: short ? 16 : 20,
      heroHeaderPadding: short ? 12 : 16,
      heroHorizontalPadding: short ? 16 : 24,
      heroVerticalPadding: short ? 14 : 24,
      heroLetterSpacing: short ? 1.1 : 2,
      heroHeaderFontSize: short ? 18 : 22,
      heroTitleFontSize: short ? 22 : 28,
      heroSubtitleFontSize: short ? 13 : 15,
      heroSubtitleGap: short ? 6 : 8,
      hideHeroSubtitle: height < 640,
      waitingVerticalPadding: short ? 20 : 32,
      waitingGap: short ? 18 : 32,
      loaderSize: short ? 28 : 36,
      difficultyCardRadius: short ? 14 : 12,
      difficultyCardPadding: short ? 16 : (medium ? 20 : 24),
      cardTitleFontSize: short ? 18 : 22,
      cardSubtitleFontSize: short ? 14 : 16,
      cardSubtitleGap: short ? 8 : 12,
      multiplierGap: short ? 6 : 8,
      multiplierHorizontalPadding: short ? 12 : 16,
      multiplierVerticalPadding: short ? 6 : 8,
      multiplierRadius: short ? 8 : 10,
      multiplierFontSize: short ? 18 : 20,
    );
  }
}
