import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';

/// Ekonomi modu — Kategori seçim ekranı (Tiyatro Temalı).
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (game.currentTask != null) {
            context.replace(
              '/task',
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

        final isMyPick = game.currentPlayerId == user?.uid;
        final marketValues = game.categoryMarketValues;
        final lockedCats = game.lockedCategories;
        final players = playersAsync.value ?? [];
        final currentPlayer = players
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final currentPickerName = currentPlayer?.name ?? 'Aktör';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'SENARYO SEÇİMİ',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
                letterSpacing: 2,
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
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
                                    ? 'SIRADAKİ AKTÖR SENSİN!'
                                    : '$currentPickerName SEÇİYOR...',
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                'SEÇİM ${game.currentPickIndex + 1}/${game.categoryPickOrder.length}',
                                style: GoogleFonts.libreBaskerville(
                                  color: Colors.white30,
                                  fontSize: 11,
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
                        'SAHNE POPÜLERLİĞİ',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white54,
                          fontSize: 13,
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
                      children: GameConstants.defaultMarketValues.keys.map((
                        cat,
                      ) {
                        final defaultVal =
                            GameConstants.defaultMarketValues[cat] ?? 1;
                        final currentVal = marketValues[cat] ?? defaultVal;
                        final isLocked = lockedCats.contains(cat);
                        return _CategoryCard(
                          category: cat,
                          currentValue: currentVal,
                          defaultValue: defaultVal,
                          isLocked: isLocked,
                          isPickable: isMyPick && !isLocked && !_isPicking,
                          onTap: () => _pickCategory(cat),
                        );
                      }).toList(),
                    ),
                  ),
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
  final bool isLocked, isPickable;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.category,
    required this.currentValue,
    required this.defaultValue,
    required this.isLocked,
    required this.isPickable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDecayed = currentValue < defaultValue;
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
            Opacity(
              opacity: isLocked ? 0.2 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 14,
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
                        '${currentValue}x',
                        style: GoogleFonts.playfairDisplay(
                          color: hasDecayed
                              ? AppColors.primary
                              : AppColors.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (hasDecayed) ...[
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
                    'ALKIŞ ÇARPANI',
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.white24,
                      fontSize: 9,
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
