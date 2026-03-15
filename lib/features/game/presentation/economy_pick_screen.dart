import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../../shared/widgets/buttons/leave_room_button.dart';
import '../providers/game_provider.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../core/constants/app_text_styles.dart';

/// Ekonomi modu — Kategori seçim ekranı (Parti Temalı).
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
      await ref
          .read(gameControllerProvider.notifier)
          .pickCategoryEconomy(
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
        final currentPlayer = players
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final currentPickerName = currentPlayer?.name ?? 'Oyuncu';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'SENARYO SEÇİMİ',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.accent,
                letterSpacing: 2,
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (isSingleCategory)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
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
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMyPick
                                      ? 'SIRADAKİ OYUNCU SENSİN!'
                                      : '$currentPickerName SEÇİYOR...',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  'SEÇİM ${game.currentPickIndex + 1}/${game.categoryPickOrder.length}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_down_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PARTİ DENEYİMİ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white54,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: marketValues.keys.map((cat) {
                          final defaultVal =
                              GameConstants.defaultMarketValues[cat] ?? 10;
                          final marketVal = marketValues[cat] ?? defaultVal;
                          final isHot = game.hotCategory == cat;
                          final displayValue = isHot ? GameConstants.hotCategoryBonus : marketVal;
                          final isLocked = lockedCats.contains(cat);
                          return _CategoryCard(
                            category: cat,
                            currentValue: displayValue,
                            defaultValue: defaultVal,
                            isHotCategory: isHot,
                            isLocked: isLocked,
                            isPickable: isMyPick && !isLocked && !_isPicking,
                            onTap: () => _pickCategory(cat),
                          );
                        }).toList(),
                      ),
                    ),
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
  final String category;
  final int currentValue, defaultValue;
  final bool isHotCategory;
  final bool isLocked, isPickable;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.category,
    required this.currentValue,
    required this.defaultValue,
    required this.isHotCategory,
    required this.isLocked,
    required this.isPickable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPickable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
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
                  size: 32,
                ),
              ),
            if (!isLocked && isHotCategory)
              Positioned(
                top: 0,
                right: 0,
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    Text(
                      'Sıcak Fırsat',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.orange,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Opacity(
              opacity: isLocked ? 0.2 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
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
                        ),
                      ),
                      if (currentValue < defaultValue) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.trending_down_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TABAN PUAN',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
