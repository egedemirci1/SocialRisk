import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/room/providers/room_provider.dart';
import '../../../features/auth/providers/user_provider.dart';
import '../../../features/economy/providers/economy_provider.dart';
import '../common/player_avatar.dart';

class ScoreboardBottomSheet extends ConsumerWidget {
  const ScoreboardBottomSheet({super.key, required this.roomCode});

  final String roomCode;

  static void show(BuildContext context, String roomCode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ScoreboardBottomSheet(roomCode: roomCode),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(watchPlayersProvider(roomCode));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.leaderboard_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Puan Durumu',
                    style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: playersAsync.when(
                  data: (players) {
                    final sortedPlayers = List.of(players)..sort((a, b) => b.score.compareTo(a.score));
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: sortedPlayers.length,
                      itemBuilder: (context, index) {
                        final player = sortedPlayers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ScoreTile(
                            rank: index + 1,
                            name: player.name,
                            score: player.score,
                            avatarUrl: player.avatarUrl,
                            activeFrame: player.activeFrame,
                            playerId: player.id,
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreTile extends ConsumerWidget {
  const _ScoreTile({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarUrl,
    this.activeFrame,
    this.playerId,
  });

  final int rank;
  final String name;
  final int score;
  final String? avatarUrl;
  final String? activeFrame;
  final String? playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = Colors.white38;
    }

    // Canlı profil — ünvan
    final profile = playerId != null
        ? ref.watch(watchUserProfileProvider(playerId!)).value
        : null;
    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];
    final titleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: AppTextStyles.titleLarge.copyWith(
                  color: rankColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PlayerAvatar(
              displayName: name,
              avatarUrl: avatarUrl,
              score: score,
              frameId: activeFrame,
              uid: playerId,
              radius: 18,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (titleItem != null)
                    Text(
                      '${titleItem.imageUrl} ${titleItem.name}',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFD4AF37),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  '$score',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
