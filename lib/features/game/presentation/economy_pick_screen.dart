import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/providers/locale_provider.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/guards/room_exit_guard.dart';
import '../../../shared/widgets/buttons/leave_room_button.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/widgets/common/game_error_scaffold.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/app_loading_indicator.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';

part 'economy_pick_screen.widgets.part.dart';

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
        final l = AppLocalizations.of(context)!;
        ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
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
    final locale = ref.watch(appLocaleProvider);
    final metrics = _EconomyPickMetrics.from(context);

    return RoomExitPopScope(
      roomCode: widget.roomCode,
      child: gameAsync.when(
      data: (game) {
        if (game == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: TheaterLoadingScreen(
              message: AppLocalizations.of(context)!.scenarioSelection,
            ),
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

          // 1. Durum Kontrolü ve Yönlendirme (Öncelikli)
          if (game.status == GameStatus.finished) {
            context.replace('/game-over', extra: widget.roomCode);
            return;
          }
          
          if (game.status == GameStatus.results) {
            context.replace(
              '/round-result',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
            return;
          }

          if (game.currentTask != null) {
            context.replace(
              '/task',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
            return;
          }

          if (game.status == GameStatus.choosingDifficulty || game.selectedCategory != null) {
            context.replace(
              '/difficulty',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
            return;
          }

          // 2. Tek Kategori Otomatik Seçim (Sadece sırası gelende)
          if (isSingleCategory &&
              singleCategory != null &&
              game.status == GameStatus.playing &&
              isMyPick &&
              !_isPicking &&
              !_autoPickFailed) {
            _pickCategory(singleCategory).catchError((_) {
              if (mounted) setState(() => _autoPickFailed = true);
            });
          }
        });

        final players = playersAsync.value ?? [];
        final currentPlayer =
            players.where((p) => p.id == game.currentPlayerId).firstOrNull;
        final currentPickerName = currentPlayer?.name ?? AppLocalizations.of(context)!.playerDefaultName;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
                                  AppLocalizations.of(context)!.scenarioSelection,
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
                    Expanded(
                      child: _autoPickFailed
                          ? Center(
                              child: AsyncErrorView(
                                message: AppLocalizations.of(context)!.autoPickFailed,
                                onRetry: () {
                                  if (singleCategory != null) {
                                    setState(() => _autoPickFailed = false);
                                    _pickCategory(singleCategory);
                                  }
                                },
                              ),
                            )
                          : const AppLoadingIndicator(),
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
                                      ? AppLocalizations.of(context)!.nextPickerIsYou
                                      : AppLocalizations.of(context)!.playerIsPicking(currentPickerName),
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
                                    AppLocalizations.of(context)!.pickCount(game.currentPickIndex + 1, game.categoryPickOrder.length),
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
                            AppLocalizations.of(context)!.partyExperience,
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
                              final marketVal =
                                  GameConstants.economyResolvedStoredBaseValue(
                                category: cat,
                                storedValues: marketValues,
                              );
                              final isHot =
                                  marketValues.length > 2 && game.hotCategory == cat;
                              final isLocked = lockedCats.contains(cat);

                              return _CategoryCard(
                                category: cat,
                                currentValue: marketVal,
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
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: TheaterLoadingScreen(
          message: AppLocalizations.of(context)!.scenarioSelection,
        ),
      ),
      error: (e, _) {
        final l = AppLocalizations.of(context)!;
        return GameErrorScaffold(
          roomCode: widget.roomCode,
          message: l.loadFailed,
          detail: ErrorMessageUtils.formatUserError(e, l),
          goHomeLabel: l.goHome,
          onRetry: () => ref.invalidate(watchGameProvider(widget.gameId)),
          onGoHome: () => context.go('/home'),
        );
      },
    ),
    );
  }
}