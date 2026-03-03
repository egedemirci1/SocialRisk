import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';

/// Ekonomi modu — Kategori seçim ekranı.
/// Sıralama bazlı: puan lideri ilk seçer, seçilen kategori değer kaybeder.
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
      await ref.read(gameControllerProvider.notifier).pickCategoryEconomy(
            gameId: widget.gameId,
            playerId: user.uid,
            category: category,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final user = ref.read(currentUserProvider);
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Görev atandıysa task_screen'e yönlendir
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (game.currentTask != null) {
            context.replace('/task', extra: {
              'gameId': widget.gameId,
              'roomCode': widget.roomCode,
            });
          } else if (game.status == GameStatus.finished) {
            context.replace('/game-over', extra: widget.roomCode);
          } else if (game.status == GameStatus.results) {
            context.replace('/round-result', extra: {
              'gameId': widget.gameId,
              'roomCode': widget.roomCode,
            });
          }
        });

        final isMyPick = game.currentPlayerId == user?.uid;
        final marketValues = game.categoryMarketValues;
        final lockedCats = game.lockedCategories;

        // Aktif seçicinin adını bul
        String currentPickerName = game.currentPlayerId;
        if (playersAsync.value != null) {
          try {
            currentPickerName = playersAsync.value!
                .firstWhere((p) => p.id == game.currentPlayerId)
                .name;
          } catch (_) {}
        }

        // Seçim sırası bilgisi
        final pickIndex = game.currentPickIndex;
        final totalPickers = game.categoryPickOrder.length;

        return Scaffold(
          backgroundColor: const Color(0xFF140D0B),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Kategori Seç',
              style: GoogleFonts.cinzelDecorative(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFDEFC2),
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded, color: Color(0xFFD4AF37)),
                onPressed: () =>
                    ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/Loading-Screen-Background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
              Container(color: const Color(0xFF140D0B).withOpacity(0.85)),
              SafeArea(
                child: ResponsiveWrapper(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                    // Sıra bilgisi
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E140F).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMyPick
                              ? const Color(0xFFD4AF37).withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              isMyPick
                                  ? Icons.star_rounded
                                  : Icons.hourglass_top_rounded,
                              color: isMyPick ? const Color(0xFFD4AF37) : Colors.white38,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMyPick
                                        ? 'Senin sıran!'
                                        : '$currentPickerName seçiyor...',
                                    style: GoogleFonts.cinzel(
                                      color: isMyPick
                                          ? const Color(0xFFD4AF37)
                                          : const Color(0xFFFDEFC2),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Seçim ${pickIndex + 1}/$totalPickers',
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Başlık
                    Row(
                      children: [
                        const Icon(Icons.trending_down_rounded,
                            color: Color(0xFFD4AF37), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Pazar Durumu',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFFDEFC2),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Kategori kartları
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: GameConstants.defaultMarketValues.keys.map((cat) {
                          final defaultVal =
                              GameConstants.defaultMarketValues[cat] ?? 1;
                          final currentVal = marketValues[cat] ?? defaultVal;
                          final isLocked = lockedCats.contains(cat);
                          final hasDecayed = currentVal < defaultVal;

                          return _CategoryCard(
                            category: cat,
                            currentValue: currentVal,
                            defaultValue: defaultVal,
                            isLocked: isLocked,
                            hasDecayed: hasDecayed,
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
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.currentValue,
    required this.defaultValue,
    required this.isLocked,
    required this.hasDecayed,
    required this.isPickable,
    required this.onTap,
  });

  final String category;
  final int currentValue;
  final int defaultValue;
  final bool isLocked;
  final bool hasDecayed;
  final bool isPickable;
  final VoidCallback onTap;

  IconData get _categoryIcon {
    switch (category) {
      case 'Cesaret':
        return Icons.bolt_rounded;
      case 'İtiraf':
        return Icons.chat_bubble_rounded;
      case 'Taklit':
        return Icons.theater_comedy_rounded;
      case 'Sosyal Medya':
        return Icons.phone_android_rounded;
      case 'Fiziksel':
        return Icons.fitness_center_rounded;
      case 'Bilgi':
        return Icons.lightbulb_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color get _categoryColor {
    if (isLocked) return Colors.grey;
    switch (category) {
      case 'Cesaret':
        return AppColors.fire;
      case 'İtiraf':
        return AppColors.glow;
      case 'Taklit':
        return AppColors.accent;
      case 'Sosyal Medya':
        return AppColors.ice;
      case 'Fiziksel':
        return AppColors.votePositive;
      case 'Bilgi':
        return AppColors.primary;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPickable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.surface.withValues(alpha: 0.5)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPickable
                ? _categoryColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Lock overlay
            if (isLocked)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_rounded, color: Colors.white38, size: 32),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _categoryIcon,
                    color: isLocked ? Colors.white24 : _categoryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isLocked ? Colors.white24 : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // Pazar değeri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${currentValue}x',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isLocked
                              ? Colors.white24
                              : (hasDecayed
                                  ? AppColors.penalty
                                  : AppColors.accent),
                          fontSize: 16,
                        ),
                      ),
                      if (hasDecayed && !isLocked) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.trending_down_rounded,
                            color: AppColors.penalty, size: 14),
                      ],
                    ],
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
