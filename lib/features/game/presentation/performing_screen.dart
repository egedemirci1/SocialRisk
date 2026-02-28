import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';

/// Görevi yapma ekranı — Görevi kabul eden kişi yapar, diğerleri izler/bekler.
class PerformingScreen extends ConsumerStatefulWidget {
  const PerformingScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<PerformingScreen> createState() => _PerformingScreenState();
}

class _PerformingScreenState extends ConsumerState<PerformingScreen> {
  bool _isProceeding = false;

  Future<void> _proceedToVoting() async {
    setState(() => _isProceeding = true);
    try {
      await ref
          .read(gameControllerProvider.notifier)
          .proceedToVoting(widget.gameId);
      // Kendi ekranı otomatik snapshot dinleyecek ama yine de anında geçmesi için:
      if (mounted) {
        context.push('/voting', extra: {
          'gameId': widget.gameId,
          'roomCode': widget.roomCode,
        });
      }
    } finally {
      if (mounted) setState(() => _isProceeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Navigate non-active players automatically when voting starts
    ref.listen(watchGameProvider(widget.gameId), (previous, next) {
      if (!mounted) return;
      final game = next.value;
      if (game == null) return;
      
      final user = ref.read(currentUserProvider);
      final isMyTurn = game.currentPlayerId == user?.uid;

      if (!isMyTurn && game.status == GameStatus.voting) {
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             context.go('/voting', extra: {
               'gameId': widget.gameId,
               'roomCode': widget.roomCode,
             });
           }
         });
      }
    });

    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevi Yapma Zamanı!'),
        automaticallyImplyLeading: false,
      ),
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: gameAsync.when(
          data: (game) {
            if (game == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final isMyTurn = game.currentPlayerId == user?.uid;
            final task = game.currentTask;
            final isClosed = roomAsync.value?.visibility == RoomVisibility.closed;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isMyTurn ? 'Görevin Ne İdi?' : 'Sıradaki Görev',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isClosed && !isMyTurn ? '❓ Gizli Görev İçeriği' : (task?.content ?? 'Bilinmiyor'),
                          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),

                if (isMyTurn) ...[
                  Text(
                    'Görevi tamamladıktan sonra oylamayı başlatabilirsiniz.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Görevi Tamamladım! Oylamaya Geç',
                    icon: Icons.how_to_vote_rounded,
                    isLoading: _isProceeding,
                    onPressed: _proceedToVoting,
                  ),
                ] else ...[
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Sırası gelen oyuncunun görevi yapması bekleniyor...',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(flex: 2),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
        ),
      ),
    );
  }
}
