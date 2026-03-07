import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../shared/utils/toast_utils.dart';

/// Kategori belirlendikten sonra oyuncunun zorluk seçtiği ekran — Tiyatro Temalı
class DifficultyChoiceScreen extends ConsumerStatefulWidget {
  final String gameId;
  final String roomCode;

  const DifficultyChoiceScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  @override
  ConsumerState<DifficultyChoiceScreen> createState() =>
      _DifficultyChoiceScreenState();
}

class _DifficultyChoiceScreenState
    extends ConsumerState<DifficultyChoiceScreen> {
  bool _isLoading = false;

  Future<void> _selectDifficulty(String difficulty) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(gameControllerProvider.notifier)
          .chooseDifficulty(gameId: widget.gameId, difficulty: difficulty);
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Hata: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: Text('Oyun bulunamadı')),
          );
        }

        final user = ref.read(currentUserProvider);
        final isMyTurn = game.currentPlayerId == user?.uid;
        final players = roomAsync.value?.players ?? [];
        final currentPlayer = players
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final playerName = currentPlayer?.name ?? 'Oyuncu';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && game.status != GameStatus.choosingDifficulty) {
            context.replace(
              '/task',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          }
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: ExitRoomButton(roomCode: widget.roomCode),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'KATEGORİ: ${game.selectedCategory?.toUpperCase() ?? "?"}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isMyTurn) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                'ZORLUK SEVİYESİ',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: AppColors.accent,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                              child: Column(
                                children: [
                                  Text(
                                    'RİSK VE ÖDÜL',
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Performansının zorluğunu sen belirle...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildDifficultyCard(
                        title: 'AMATÖR',
                        multiplier: '1x',
                        color: Colors.green,
                        onTap: () => _selectDifficulty('easy'),
                      ),
                      const SizedBox(height: 16),
                      _buildDifficultyCard(
                        title: 'PROFESYONEL',
                        multiplier: '2x',
                        color: Colors.orange,
                        onTap: () => _selectDifficulty('medium'),
                      ),
                      const SizedBox(height: 16),
                      _buildDifficultyCard(
                        title: 'DUAYEN',
                        multiplier: '3x',
                        color: AppColors.primary,
                        onTap: () => _selectDifficulty('hard'),
                      ),
                    ] else ...[
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                'BEKLENİYOR',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: AppColors.accent,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(color: AppColors.accent),
                                  const SizedBox(height: 32),
                                  Text(
                                    '$playerName zorluk seviyesini seçiyor...',
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(flex: 2),
                  ],
                ),
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

  Widget _buildDifficultyCard({
    required String title,
    required String multiplier,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                multiplier,
                style: AppTextStyles.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
