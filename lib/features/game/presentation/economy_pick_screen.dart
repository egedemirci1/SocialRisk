import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/buttons/leave_room_button.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';

class EconomyPickScreen extends ConsumerStatefulWidget {
  const EconomyPickScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<EconomyPickScreen> createState() => _EconomyPickScreenState();
}

class _EconomyPickScreenState extends ConsumerState<EconomyPickScreen> {
  bool _isPicking = false;
  bool _autoPickFailed = false;

  Future<void> _pickCategory(String category) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      await ref.read(gameControllerProvider.notifier).pickCategoryEconomy(
            gameId: widget.gameId,
            playerId: user.uid,
            category: category,
          );
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Hata: $e');
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final user = ref.read(currentUserProvider);
    final metrics = _EconomyPickMetrics.from(context);

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final marketValues = game.categoryMarketValues;
        final lockedCats = game.lockedCategories;
        final categories = marketValues.keys.toList();
        final isSingleCategory = categories.length == 1;
        final singleCategory = isSingleCategory ? categories.first : null;
        final isMyPick = game.currentPlayerId == user?.uid;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (isSingleCategory &&
              singleCategory != null &&
              game.currentTask == null &&
              game.selectedCategory == null &&
              game.status == GameStatus.playing &&
              isMyPick &&
              !_isPicking &&
              !_autoPickFailed) {
            _pickCategory(singleCategory).catchError((_) {
              if (mounted) setState(() => _autoPickFailed = true);
            });
          } else if (game.currentTask != null) {
            context.replace(
              '/task',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          } else if (game.status == GameStatus.choosingDifficulty) {
            context.replace(
              '/difficulty',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          } else if (game.status == GameStatus.finished) {
            context.replace('/game-over', extra: widget.roomCode);
          } else if (game.status == GameStatus.results) {
            context.replace(
              '/round-result',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          }
        });

        final players = playersAsync.value ?? [];
        final currentPlayer =
            players.where((p) => p.id == game.currentPlayerId).firstOrNull;
        final currentPickerName = currentPlayer?.name ?? 'Oyuncu';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
                                  'SENARYO SEÇİMİ',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.accent,
                letterSpacing: metrics.titleLetterSpacing,
                fontSize: metrics.titleFontSize,
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
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
            child: ResponsiveWrapper(
              padding: EdgeInsets.symmetric(horizontal: metrics.screenPadding),
              child: Column(
                children: [
                  SizedBox(height: metrics.sectionGap),
                  if (isSingleCategory)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    )
                  else ...[
                    Container(
                      padding: EdgeInsets.all(metrics.infoPadding),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(metrics.infoRadius),
                        border: Border.all(
                          color: isMyPick
                              ? AppColors.accent.withValues(alpha: 0.3)
                              : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isMyPick
                                ? Icons.star_rounded
                                : Icons.hourglass_top_rounded,
                            color: isMyPick ? AppColors.accent : Colors.white24,
                            size: metrics.infoIconSize,
                          ),
                          SizedBox(width: metrics.inlineGap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMyPick
                                      ? 'SIRADAKI OYUNCU SENSIN!'
                                      : '$currentPickerName SEÇİYOR...',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    fontSize: metrics.infoTitleFontSize,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                    'SEÇİM ${game.currentPickIndex + 1}/${game.categoryPickOrder.length}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white30,
                                    fontSize: metrics.helperFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: metrics.sectionGapLarge),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_down_rounded,
                          color: AppColors.accent,
                          size: metrics.helperIconSize,
                        ),
                        SizedBox(width: metrics.textGap),
                        Expanded(
                          child: Text(
                            'PARTI DENEYIMI',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white54,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              fontSize: metrics.helperFontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: metrics.sectionGap),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth < 280
                              ? 1
                              : constraints.maxWidth < 500
                                  ? 2
                                  : constraints.maxWidth < 800
                                      ? 3
                                      : 4;

                          final rowCount = (marketValues.length / crossAxisCount).ceil();
                          final totalSpacingHeight =
                              max(0.0, metrics.gridSpacing * (rowCount - 1));
                          final totalSpacingWidth =
                              max(0.0, metrics.gridSpacing * (crossAxisCount - 1));
                          
                          // Ekrandaki boş alana tam sığacak dinamik en/boy oranı formülü:
                          final idealItemHeight =
                              (constraints.maxHeight - totalSpacingHeight) / rowCount;
                          final idealItemWidth =
                              (constraints.maxWidth - totalSpacingWidth) / crossAxisCount;

                          // Çok uzamasın diye makul bir max değere kilitlenebilir, ancak minimum değer 
                          // kesinlikle eldeki yüksekliği aşmasına (scroll'a) izin vermeyecek.
                          final dynamicAspectRatio = idealItemWidth / max(1.0, idealItemHeight);
                          
                          // Aşırı yassı olmasını engelle (eğer dikeyde çok boşluk varsa)
                          // Ama scroll'a girmemesi için asla ideal hesabın ALTINA düşme
                          final finalAspectRatio = max(dynamicAspectRatio, 1.1);

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(), // Scroll tamamen imkansız
                            padding: EdgeInsets.zero,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: metrics.gridSpacing,
                              mainAxisSpacing: metrics.gridSpacing,
                              childAspectRatio: finalAspectRatio,
                            ),
                            itemCount: marketValues.length,
                            itemBuilder: (context, index) {
                              final cat = marketValues.keys.elementAt(index);
                              final defaultVal =
                                  GameConstants.defaultMarketValues[cat] ?? 10;
                              final marketVal = marketValues[cat] ?? defaultVal;
                              final isHot = game.hotCategory == cat;
                              final displayValue = isHot
                                  ? GameConstants.hotCategoryBonus
                                  : marketVal;
                              final isLocked = lockedCats.contains(cat);

                              return _CategoryCard(
                                category: cat,
                                currentValue: displayValue,
                                defaultValue: defaultVal,
                                isHotCategory: isHot,
                                isLocked: isLocked,
                                isPickable: isMyPick && !isLocked && !_isPicking,
                                onTap: () => _pickCategory(cat),
                                compact: metrics.isCompact,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: metrics.sectionGapLarge),
                  ],
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
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.currentValue,
    required this.defaultValue,
    required this.isHotCategory,
    required this.isLocked,
    required this.isPickable,
    required this.onTap,
    required this.compact,
  });

  final String category;
  final int currentValue;
  final int defaultValue;
  final bool isHotCategory;
  final bool isLocked;
  final bool isPickable;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 12.0 : 16.0;
    final titleSize = compact ? 14.0 : 16.0;
    final valueSize = compact ? 18.0 : 20.0;
    final helperSize = compact ? 10.0 : 12.0;

    return GestureDetector(
      onTap: isPickable ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
          border: Border.all(
            color: isPickable
                ? AppColors.accent.withValues(alpha: 0.3)
                : Colors.white10,
          ),
        ),
        child: Stack(
          children: [
            if (isLocked)
              Center(
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white10,
                  size: compact ? 28 : 32,
                ),
              ),
            if (!isLocked && isHotCategory)
              Positioned(
                top: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.orange,
                      size: compact ? 16 : 18,
                    ),
                    Text(
                      'Sicak\nFirsat',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.orange,
                        fontSize: compact ? 6 : 7,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            // Extra top padding so hot deal badge never overlaps category name
            Opacity(
              opacity: isLocked ? 0.2 : 1.0,
              child: Padding(
                padding: EdgeInsets.only(
                  top: (!isLocked && isHotCategory) ? (compact ? 24.0 : 28.0) : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.toUpperCase(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: compact ? 0.6 : 1,
                      fontSize: titleSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currentValue',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: currentValue < defaultValue
                              ? AppColors.primary
                              : AppColors.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: valueSize,
                        ),
                      ),
                      if (currentValue < defaultValue) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.trending_down_rounded,
                          color: AppColors.primary,
                          size: compact ? 12 : 14,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: compact ? 2 : 4),
                  Text(
                    'TABAN PUAN',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white24,
                      fontSize: helperSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _EconomyPickMetrics {
  const _EconomyPickMetrics({
    required this.isCompact,
    required this.screenPadding,
    required this.sectionGap,
    required this.sectionGapLarge,
    required this.inlineGap,
    required this.textGap,
    required this.titleFontSize,
    required this.titleLetterSpacing,
    required this.infoPadding,
    required this.infoRadius,
    required this.infoIconSize,
    required this.infoTitleFontSize,
    required this.helperFontSize,
    required this.helperIconSize,
    required this.gridSpacing,
    required this.singleColumnAspectRatio,
    required this.doubleColumnAspectRatio,
  });

  final bool isCompact;
  final double screenPadding;
  final double sectionGap;
  final double sectionGapLarge;
  final double inlineGap;
  final double textGap;
  final double titleFontSize;
  final double titleLetterSpacing;
  final double infoPadding;
  final double infoRadius;
  final double infoIconSize;
  final double infoTitleFontSize;
  final double helperFontSize;
  final double helperIconSize;
  final double gridSpacing;
  final double singleColumnAspectRatio;
  final double doubleColumnAspectRatio;

  factory _EconomyPickMetrics.from(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 390 || size.height < 700;
    final isTiny = size.height < 680;

    return _EconomyPickMetrics(
      isCompact: isCompact,
      screenPadding: isTiny ? 12 : (isCompact ? 16 : 24),
      sectionGap: isTiny ? 8 : (isCompact ? 12 : 20),
      sectionGapLarge: isTiny ? 12 : (isCompact ? 18 : 28),
      inlineGap: isTiny ? 6 : (isCompact ? 10 : 12),
      textGap: isCompact ? 6 : 8,
      titleFontSize: isTiny ? 14 : (isCompact ? 16 : 20),
      titleLetterSpacing: isCompact ? 1.0 : 2,
      infoPadding: isTiny ? 12 : (isCompact ? 14 : 18),
      infoRadius: isCompact ? 10 : 14,
      infoIconSize: isTiny ? 20 : (isCompact ? 24 : 28),
      infoTitleFontSize: isTiny ? 13 : (isCompact ? 14 : 16),
      helperFontSize: isCompact ? 11 : 12,
      helperIconSize: isCompact ? 14 : 18,
      gridSpacing: isTiny ? 8 : (isCompact ? 12 : 16),
      singleColumnAspectRatio: isTiny ? 3.5 : (isCompact ? 3.0 : 2.5),
      // Miktar yassı tutularak tüm cihazlarda scrollsuz görünüm hedefleniyor
      doubleColumnAspectRatio: isTiny ? 1.6 : (isCompact ? 1.45 : 1.35),
    );
  }
}
