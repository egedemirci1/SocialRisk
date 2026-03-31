import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import '../../../shared/widgets/common/loading_overlay.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/domain/user_entity.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  bool _isScoreMode = false;
  double _scoreTarget = GameConstants.defaultTargetScore.toDouble();
  double _roundTarget = GameConstants.defaultMaxRounds.toDouble();
  bool _isCreating = false;
  final List<String> _selectedCategories =
      GameConstants.defaultCategoriesConst.toList();
  GameMode _selectedMode = GameMode.classic;

  @override
  void initState() {
    super.initState();
    ref.read(audioServiceProvider).playMenuLoop();
  }

  Future<void> _createRoom() async {
    setState(() => _isCreating = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final endType =
          _isScoreMode ? EndConditionType.score : EndConditionType.rounds;
      final endValue =
          _isScoreMode ? _scoreTarget.toInt() : _roundTarget.toInt();

      final userProfile =
          await ref.read(userRepositoryProvider).getUserProfile(user.uid);
      final repo = ref.read(roomRepositoryProvider);
      final effectiveMode = _selectedCategories.length == 1
          ? GameMode.economy
          : _selectedMode;

      final roomCode = await repo.createRoom(
        hostId: user.uid,
        hostName: user.displayName ?? AppLocalizations.of(context)!.hostDefaultName,
        endConditionType: endType,
        endConditionValue: endValue,
        visibility: RoomVisibility.open,
        categories: _selectedCategories,
        hostAvatarUrl: userProfile?.avatarUrl,
        mode: effectiveMode,
        useCustomDeck: _selectedCategories.contains('Özel'),
      );

      if (mounted && roomCode.isNotEmpty) {
        context.push('/lobby', extra: roomCode);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, AppLocalizations.of(context)!.error(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _CreateRoomMetrics.from(context);
    final user = ref.watch(currentUserProvider);
    final userProfile = user != null
        ? ref.watch(watchUserProfileProvider(user.uid)).value
        : null;
    final isPremium = userProfile?.isPremium ?? false;

    Widget buildContent(double availableWidth) {
      return SizedBox(
        width: availableWidth,
        child: Container(
          padding: EdgeInsets.all(metrics.cardPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF130D26).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(metrics.cardRadius),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: metrics.isCompactHeight ? 28 : 40,
                offset: Offset(0, metrics.isCompactHeight ? 14 : 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.newPartyHostTitle,
                style: AppTextStyles.displayMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: metrics.titleFontSize,
                  color: Colors.white,
                  letterSpacing: 1.0,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 4),
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: metrics.sectionGapLarge),
              _buildSection(
                metrics: metrics,
                title: AppLocalizations.of(context)!.endConditionLabel,
                icon: Icons.flag_rounded,
                child: _buildEndCondition(metrics),
              ),
              SizedBox(height: metrics.sectionGap),
              _buildSection(
                metrics: metrics,
                title: AppLocalizations.of(context)!.gameModeLabel,
                icon: Icons.celebration_rounded,
                child: _buildGameMode(metrics),
              ),
              SizedBox(height: metrics.sectionGap),
              _buildSection(
                metrics: metrics,
                title: AppLocalizations.of(context)!.categoriesLabel,
                icon: Icons.category_rounded,
                child: _buildCategorySelector(metrics, isPremium),
              ),
              SizedBox(height: metrics.actionTopSpacing),
              SizedBox(
                width: double.infinity,
                child: StageButton(
                    label: AppLocalizations.of(context)!.startPartyButton,
                  icon: Icons.play_arrow_rounded,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.background,
                  borderColor: Colors.transparent,
                  onPressed: _createRoom,
                  isLoading: _isCreating,
                  compact: metrics.isCompactWidth || metrics.isCompactHeight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LoadingOverlay(
      isLoading: _isCreating,
      message: AppLocalizations.of(context)!.roomCreating,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.accent,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: AnimatedMeshBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalInset = metrics.outerHorizontalPadding * 2;
                  final availableWidth = math.max(
                    280.0,
                    math.min(
                      metrics.contentMaxWidth,
                      constraints.maxWidth - horizontalInset,
                    ),
                  );

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        metrics.outerHorizontalPadding,
                        metrics.outerVerticalPadding,
                        metrics.outerHorizontalPadding,
                        metrics.outerVerticalPadding + metrics.safeBottomSpacing,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: buildContent(availableWidth),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                onTap: () => setState(() => _isScoreMode = false),
                compact: metrics.isCompactWidth || metrics.isCompactHeight,
              ),
            ),
            SizedBox(width: metrics.inlineGap),
            Expanded(
              child: _ToggleChip(
                label: AppLocalizations.of(context)!.pointLabel,
                isSelected: _isScoreMode,
                onTap: () => setState(() => _isScoreMode = true),
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
                  setState(() => _scoreTarget = value);
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
                  setState(() => _roundTarget = value);
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

  Widget _buildGameMode(_CreateRoomMetrics metrics) {
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
                  if (_selectedCategories.length == 1) {
                    ToastUtils.showInfo(
                      context,
                        AppLocalizations.of(context)!.singleCategoryEconomyWarn,
                    );
                    return;
                  }
                  HapticFeedback.lightImpact();
                  setState(() => _selectedMode = GameMode.classic);
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
                  setState(() => _selectedMode = GameMode.economy);
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
                onTap: () {
                  if (categoryId == 'Özel' && !isPremium) {
                    HapticFeedback.heavyImpact();
                    ToastUtils.showInfo(
                      context,
                      AppLocalizations.of(context)!.premiumCategoryLocked,
                    );
                    return;
                  }
                  setState(() {
                    if (isSelected) {
                      if (_selectedCategories.length > 1) {
                        _selectedCategories.remove(categoryId);
                        if (_selectedCategories.length == 1 &&
                            _selectedMode != GameMode.economy) {
                          _selectedMode = GameMode.economy;
                          ToastUtils.showInfo(
                            context,
                  AppLocalizations.of(context)!.singleCategoryEconomyAutoChange,
                          );
                        }
                      } else {
                        ToastUtils.showWarning(
                          context,
                  AppLocalizations.of(context)!.minOneCategoryWarn,
                        );
                      }
                    } else {
                      _selectedCategories.add(categoryId);
                    }
                  });
                },
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
                        if (categoryId == 'Özel' && !isPremium) ...[
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
                                  : (categoryId == 'Özel' && !isPremium)
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

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final verticalPadding = compact ? 6.0 : 8.0;
    final fontSize = compact ? 12.0 : 13.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10, width: 1.5),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.transparent,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.background : Colors.white54,
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            ),
            child: Center(child: Text(label)),
          ),
        ],
      ),
    );
  }
}

class _CreateRoomMetrics {
  const _CreateRoomMetrics({
    required this.isCompactWidth,
    required this.isCompactHeight,
    required this.outerHorizontalPadding,
    required this.outerVerticalPadding,
    required this.safeBottomSpacing,
    required this.contentMaxWidth,
    required this.cardPadding,
    required this.cardRadius,
    required this.titleFontSize,
    required this.sectionGapLarge,
    required this.sectionGap,
    required this.actionTopSpacing,
    required this.sectionPadding,
    required this.sectionRadius,
    required this.sectionIconSize,
    required this.inlineGap,
    required this.sectionTitleFontSize,
    required this.sectionInnerGap,
    required this.contentGap,
    required this.valueFontBase,
    required this.valueFontDelta,
    required this.sliderTrackHeight,
    required this.sliderLabelOffset,
    required this.sliderLabelHorizontalPadding,
    required this.helperFontSize,
    required this.infoBoxPadding,
    required this.infoBoxRadius,
    required this.infoIconSize,
    required this.infoTitleFontSize,
    required this.textTightGap,
    required this.bodyFontSize,
    required this.bodyLineHeight,
    required this.chipSpacing,
    required this.chipRunSpacing,
    required this.minCategoryChipWidth,
    required this.categoryChipHorizontalPadding,
    required this.categoryChipVerticalPadding,
    required this.categorySoonFontSize,
    required this.categoryFontSize,
  });

  final bool isCompactWidth;
  final bool isCompactHeight;
  final double outerHorizontalPadding;
  final double outerVerticalPadding;
  final double safeBottomSpacing;
  final double contentMaxWidth;
  final double cardPadding;
  final double cardRadius;
  final double titleFontSize;
  final double sectionGapLarge;
  final double sectionGap;
  final double actionTopSpacing;
  final double sectionPadding;
  final double sectionRadius;
  final double sectionIconSize;
  final double inlineGap;
  final double sectionTitleFontSize;
  final double sectionInnerGap;
  final double contentGap;
  final double valueFontBase;
  final double valueFontDelta;
  final double sliderTrackHeight;
  final double sliderLabelOffset;
  final double sliderLabelHorizontalPadding;
  final double helperFontSize;
  final double infoBoxPadding;
  final double infoBoxRadius;
  final double infoIconSize;
  final double infoTitleFontSize;
  final double textTightGap;
  final double bodyFontSize;
  final double bodyLineHeight;
  final double chipSpacing;
  final double chipRunSpacing;
  final double minCategoryChipWidth;
  final double categoryChipHorizontalPadding;
  final double categoryChipVerticalPadding;
  final double categorySoonFontSize;
  final double categoryFontSize;

  factory _CreateRoomMetrics.from(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final shortestSide = mediaQuery.size.shortestSide;
    final isCompactWidth = width < 390;
    final isCompactHeight = height < 780;
    final isVerySmall = shortestSide < 360 || height < 720;

    return _CreateRoomMetrics(
      isCompactWidth: isCompactWidth,
      isCompactHeight: isCompactHeight,
      outerHorizontalPadding: isCompactWidth ? 12 : 16,
      outerVerticalPadding: isCompactHeight ? 6 : 10,
      safeBottomSpacing: mediaQuery.viewPadding.bottom,
      contentMaxWidth: 560,
      cardPadding: isVerySmall ? 14 : 18,
      cardRadius: isCompactWidth ? 24 : 30,
      titleFontSize: isVerySmall ? 20 : 23,
      sectionGapLarge: isVerySmall ? 10 : 14,
      sectionGap: isVerySmall ? 8 : 10,
      actionTopSpacing: isVerySmall ? 12 : 16,
      sectionPadding: isVerySmall ? 8 : 10,
      sectionRadius: isCompactWidth ? 20 : 24,
      sectionIconSize: isCompactWidth ? 16 : 18,
      inlineGap: isVerySmall ? 6 : 8,
      sectionTitleFontSize: isVerySmall ? 14 : 15,
      sectionInnerGap: isVerySmall ? 8 : 10,
      contentGap: isVerySmall ? 8 : 10,
      valueFontBase: isVerySmall ? 14 : 16,
      valueFontDelta: isVerySmall ? 8 : 10,
      sliderTrackHeight: isVerySmall ? 4 : 5,
      sliderLabelOffset: isVerySmall ? 12 : 14,
      sliderLabelHorizontalPadding: isVerySmall ? 2 : 4,
      helperFontSize: isVerySmall ? 10 : 11,
      infoBoxPadding: isVerySmall ? 10 : 12,
      infoBoxRadius: isCompactWidth ? 14 : 16,
      infoIconSize: isCompactWidth ? 20 : 22,
      infoTitleFontSize: isVerySmall ? 13 : 14,
      textTightGap: isVerySmall ? 2 : 4,
      bodyFontSize: isVerySmall ? 11 : 12,
      bodyLineHeight: isVerySmall ? 1.2 : 1.3,
      chipSpacing: isVerySmall ? 6 : 8,
      chipRunSpacing: isVerySmall ? 6 : 8,
      minCategoryChipWidth: isVerySmall ? 78 : 90,
      categoryChipHorizontalPadding: isVerySmall ? 6 : 8,
      categoryChipVerticalPadding: isVerySmall ? 6 : 8,
      categorySoonFontSize: isVerySmall ? 9 : 10,
      categoryFontSize: isVerySmall ? 11 : 12,
    );
  }
}
