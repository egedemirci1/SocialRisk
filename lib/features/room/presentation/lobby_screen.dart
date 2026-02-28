import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/danger_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/room_provider.dart';
import '../../game/providers/game_provider.dart';
import '../../../shared/models/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Lobi ekranı — Oyuncu listesi, hazır/değil durumu, ve Başla butonu.
class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final playersAsync = ref.watch(watchPlayersProvider(roomCode));
    final roomAsync = ref.watch(watchRoomProvider(roomCode));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () async {
            if (user != null) {
              await ref.read(roomControllerProvider.notifier).leaveRoom(
                roomCode: roomCode,
                playerId: user.uid,
              );
            }
            if (context.mounted) context.pop();
          },
        ),
      ),
      body: GradientContainer(
        child: Column(
          children: [
            // Oda kodu banner
            _buildRoomCodeBanner(context),

            const SizedBox(height: 16),

            // Oyuncu listesi
            Expanded(
              child: playersAsync.when(
                data: (players) => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isMe = player.id == user?.uid;
                    return _PlayerTile(
                      name: player.name,
                      isReady: player.isReady,
                      isCurrentPlayer: isMe,
                      score: player.score,
                    );
                  },
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Hata: $e')),
              ),
            ),

            // Alt butonlar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: roomAsync.when(
                data: (room) {
                  final isHost = room?.hostId == user?.uid;
                  final players = playersAsync.value ?? [];
                  final allReady = players.isNotEmpty &&
                      players.every((p) => p.id == room?.hostId || p.isReady);

                  // Non-host: oyun başladığında otomatik yönlendir
                  if (!isHost && room?.status == GameStatus.playing) {
                    final gameId = room?.gameId;
                    if (gameId != null && gameId.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          context.go('/task', extra: {
                            'gameId': gameId,
                            'roomCode': roomCode,
                          });
                        }
                      });
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isHost) ...[
                        // Hazır butonu — host değil
                        _ReadyToggleButton(
                          roomCode: roomCode,
                          playerId: user?.uid ?? '',
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (isHost) ...[
                        // Başla butonu — sadece host
                        PrimaryButton(
                          label: 'Oyunu Başlat',
                          icon: Icons.play_arrow_rounded,
                          onPressed: (allReady && players.length >= 2)
                              ? () async {
                                  try {
                                    final playerIds =
                                        players.map((p) => p.id).toList();

                                    // Repository'leri async gap öncesi yakala
                                    final roomRepo =
                                        ref.read(roomRepositoryProvider);
                                    final gameRepo =
                                        ref.read(gameRepositoryProvider);

                                    await roomRepo.updateRoomStatus(
                                      roomCode: roomCode,
                                      status: GameStatus.playing,
                                    );
                                    final gameId = await gameRepo.startGame(
                                      roomId: roomCode,
                                      playerIds: playerIds,
                                    );

                                    // gameId'yi room belgesine yaz
                                    await FirebaseFirestore.instance
                                        .collection('rooms')
                                        .doc(roomCode)
                                        .update({'currentGameId': gameId});

                                    if (context.mounted) {
                                      context.go('/task', extra: {
                                        'gameId': gameId,
                                        'roomCode': roomCode,
                                      });
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Hata: ${e.toString()}')),
                                      );
                                    }
                                  }
                                }
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          allReady
                              ? 'Tüm oyuncular hazır!'
                              : 'Herkesin hazır olmasını bekle...',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: allReady
                                ? AppColors.votePositive
                                : Colors.white38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Hata: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCodeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oda Kodu',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roomCode,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.white54),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: roomCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kod kopyalandı!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.name,
    required this.isReady,
    required this.isCurrentPlayer,
    this.score = 0,
  });

  final String name;
  final bool isReady;
  final bool isCurrentPlayer;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isCurrentPlayer
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentPlayer
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              PlayerAvatar(
                displayName: name,
                score: score,
                radius: 20,
              ),
              const SizedBox(width: 12),
              Text(
                name + (isCurrentPlayer ? ' (Sen)' : ''),
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              const Spacer(),
              Icon(
                isReady
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isReady ? AppColors.votePositive : Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadyToggleButton extends ConsumerWidget {
  const _ReadyToggleButton({
    required this.roomCode,
    required this.playerId,
  });

  final String roomCode;
  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(watchPlayersProvider(roomCode));
    final players = playersAsync.value ?? [];
    final me = players.cast<dynamic>().firstWhere(
          (p) => p.id == playerId,
          orElse: () => null,
        );
    final isReady = me?.isReady ?? false;

    return isReady
        ? DangerButton(
            label: 'Hazır Değilim',
            icon: Icons.close_rounded,
            outlined: true,
            onPressed: () => ref
                .read(roomControllerProvider.notifier)
                .toggleReady(
                    roomCode: roomCode,
                    playerId: playerId,
                    isReady: false),
          )
        : PrimaryButton(
            label: 'Hazırım!',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () => ref
                .read(roomControllerProvider.notifier)
                .toggleReady(
                    roomCode: roomCode,
                    playerId: playerId,
                    isReady: true),
          );
  }
}
