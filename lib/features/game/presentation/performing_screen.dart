import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';
import 'widgets/player_spotlight.dart';
import 'widgets/spectator_strip.dart';
import 'widgets/turn_counter_badge.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../core/constants/app_text_styles.dart';

/// Gösteri (Performing) Ekranı — Parti Temalı
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
      if (mounted) {
        context.push(
          '/voting',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
      }
    } finally {
      if (mounted) setState(() => _isProceeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(watchGameProvider(widget.gameId), (previous, next) {
      if (!mounted) return;
      final game = next.value;
      if (game == null) return;
      final user = ref.read(currentUserProvider);
      final isMyTurn = game.currentPlayerId == user?.uid;

      if (!isMyTurn &&
          game.status == GameStatus.voting &&
          previous?.value?.status != GameStatus.voting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(
              '/voting',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          }
        });
      }
    });

    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));
    final user = ref.watch(currentUserProvider);
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'GÖSTERİ BAŞLADI',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.accent,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: ExitRoomButton(roomCode: widget.roomCode),
        actions: [
          if (roomAsync.value != null && gameAsync.value != null)
            TurnCounterBadge(
              currentRound: gameAsync.value!.currentRound,
              endConditionType: roomAsync.value!.endConditionType,
              endConditionValue: roomAsync.value!.endConditionValue,
            ),
        ],
      ),
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isMyTurn = game.currentPlayerId == user?.uid;
          final task = game.currentTask;
          final isClosed = roomAsync.value?.visibility == RoomVisibility.closed;
          final players = playersAsync.value ?? [];
          final currentPlayer = players
              .where((p) => p.id == game.currentPlayerId)
              .firstOrNull;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentPlayer != null)
                        PlayerSpotlight(player: currentPlayer, isMe: isMyTurn),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              isMyTurn ? 'SENARYONUZ:' : 'SERGİLENEN ROL:',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isClosed && !isMyTurn
                                  ? 'GİZLİ SENARYO'
                                  : (task?.content ?? 'Rol belirtilmemiş'),
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      if (isMyTurn) ...[
                        Text(
                          'Senaryoyu sergilediyseniz performansınızı bitirin.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white54,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        StageButton(
                          label: 'Performansı Bitir',
                          icon: Icons.how_to_vote_rounded,
                          backgroundColor: AppColors.primary,
                          textColor: Colors.white,
                          borderColor: AppColors.accent,
                          onPressed: _proceedToVoting,
                          isLoading: _isProceeding,
                        ),
                      ] else ...[
                        const CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Oyuncunun performansını sergilemesi bekleniyor...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white54,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (players.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  child: SpectatorStrip(
                    players: players,
                    currentPlayerId: game.currentPlayerId,
                    myPlayerId: user?.uid,
                  ),
                ),
            ],
          );
        },
        loading: () => Scaffold(
          backgroundColor: Colors.transparent,
          body: const TheaterLoadingScreen(message: 'Oyuncu Bekleniyor...'),
        ),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
