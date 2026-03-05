import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
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
            backgroundColor: AppColors.background,
            body: Center(child: Text('Oyun bulunamadı')),
          );
        }

        final user = ref.read(currentUserProvider);
        final isMyTurn = game.currentPlayerId == user?.uid;
        final players = roomAsync.value?.players ?? [];
        final currentPlayer = players
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final playerName = currentPlayer?.name ?? 'Aktör';

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
            title: Text(
              isMyTurn ? 'ZORLUK SEVİYESİ' : 'BEKLENİYOR',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
                letterSpacing: 2,
              ),
            ),
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
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isMyTurn) ...[
                      Text(
                        'RİSK VE ÖDÜL DENGESİ',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Performansının zorluğunu sen belirle...',
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
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
                      const CircularProgressIndicator(color: AppColors.accent),
                      const SizedBox(height: 32),
                      Text(
                        '$playerName zorluk seviyesini seçiyor...',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
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
                style: GoogleFonts.playfairDisplay(
                  color: color,
                  fontSize: 20,
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
                style: GoogleFonts.playfairDisplay(
                  color: color,
                  fontSize: 18,
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
