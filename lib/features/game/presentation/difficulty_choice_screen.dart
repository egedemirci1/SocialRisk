import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../../shared/models/enums.dart';

/// Kategori belirlendikten sonra oyuncunun zorluk (risk/ödül) seçtiği ekran.
class DifficultyChoiceScreen extends ConsumerStatefulWidget {
  final String gameId;
  final String roomCode;

  const DifficultyChoiceScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  @override
  ConsumerState<DifficultyChoiceScreen> createState() => _DifficultyChoiceScreenState();
}

class _DifficultyChoiceScreenState extends ConsumerState<DifficultyChoiceScreen> {
  bool _isLoading = false;

  Future<void> _selectDifficulty(String difficulty) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(gameControllerProvider.notifier).chooseDifficulty(
        gameId: widget.gameId,
        roomId: widget.roomCode,
        difficulty: difficulty,
      );
      // Seçim başarılı olduğunda GameStatus 'playing' veya 'performing' olacak,
      // dinleyici (listen) task_screen'e geri yönlendirebilir veya router halledecek.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
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
        if (game == null) return const Scaffold(body: Center(child: Text('Oyun bulunamadı')));

        final isMyTurn = game.currentPlayerId == ref.read(currentUserProvider)?.uid;
        final currentPlayerName = roomAsync.value?.players
                .firstWhere((p) => p.id == game.currentPlayerId)
                .name ?? 'Oyuncu';
                
        // Eğer statüs değiştiyse (örn. playing olduysa), görev ekranına dön
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && game.status != GameStatus.choosingDifficulty) {
            context.replace('/task', extra: {
              'gameId': widget.gameId,
              'roomCode': widget.roomCode,
            });
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFF140D0B),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              isMyTurn ? 'Zorluk Seç' : 'Bekleniyor...',
              style: GoogleFonts.cinzelDecorative(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFDEFC2),
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Seçilen kategori göstergesi
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E140F).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Kategori: ${game.selectedCategory ?? "?"}',
                            style: GoogleFonts.cinzel(
                              color: const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      if (isMyTurn) ...[
                        Text(
                          'Ne kadar risk, o kadar puan!',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFFDEFC2),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Zorluğu seç ve görevini öğren.',
                          style: GoogleFonts.cinzel(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        _buildDifficultyCard(
                          title: 'Kolay',
                          multiplier: '1x',
                          description: 'Rahat ve keyifli bir başlangıç.',
                          color: Colors.green.shade400,
                          onTap: () => _selectDifficulty('easy'),
                        ),
                        const SizedBox(height: 16),

                        _buildDifficultyCard(
                          title: 'Orta',
                          multiplier: '2x',
                          description: 'Biraz zorlu ama yapılabilir.',
                          color: Colors.orange.shade400,
                          onTap: () => _selectDifficulty('medium'),
                        ),
                        const SizedBox(height: 16),

                        _buildDifficultyCard(
                          title: 'Zor',
                          multiplier: '3x',
                          description: 'Sınırlarını zorlamaya hazır ol!',
                          color: Colors.red.shade400,
                          onTap: () => _selectDifficulty('hard'),
                        ),
                      ] else ...[
                        CircularProgressIndicator(
                          color: const Color(0xFFD4AF37),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '$currentPlayerName zorluk seçiyor...',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFFDEFC2),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kategori: ${game.selectedCategory}',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFD4AF37),
                            fontSize: 18,
                          ),
                        ),
                      ],

                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }

  Widget _buildDifficultyCard({
    required String title,
    required String multiplier,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Sol: Başlık ve Açıklama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Sağ: Çarpan
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    multiplier,
                    style: AppTextStyles.headlineMedium.copyWith(color: color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
