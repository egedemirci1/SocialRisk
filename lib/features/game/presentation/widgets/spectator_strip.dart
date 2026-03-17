import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/common/player_avatar.dart';
import '../../../auth/providers/user_provider.dart';
import '../../../economy/providers/economy_provider.dart';
import '../../../room/domain/room_entity.dart';

/// Oyun ekranındaki diğer oyuncuları küçük avatarlarla gösteren şerit.
class SpectatorStrip extends ConsumerWidget {
  final List<PlayerEntity> players;
  final String currentPlayerId;
  final String? myPlayerId;

  const SpectatorStrip({
    super.key,
    required this.players,
    required this.currentPlayerId,
    this.myPlayerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece sırası olmayan seyircileri göster
    final spectators = players.where((p) => p.id != currentPlayerId).toList();

    if (spectators.isEmpty) return const SizedBox.shrink();

    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];

    final stripHeight = (MediaQuery.sizeOf(context).height * 0.11).clamp(70.0, 90.0);

    return SizedBox(
      height: stripHeight,
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: spectators.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final player = spectators[index];
            final isMe = player.id == myPlayerId;

            return _SpectatorItem(
              player: player,
              isMe: isMe,
              cosmetics: cosmetics,
            );
          },
        ),
      ),
    );
  }
}

class _SpectatorItem extends ConsumerWidget {
  const _SpectatorItem({
    required this.player,
    required this.isMe,
    required this.cosmetics,
  });

  final PlayerEntity player;
  final bool isMe;
  final List cosmetics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(watchUserProfileProvider(player.id));
    final profile = profileAsync.value;
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMe ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: PlayerAvatar(
            displayName: player.name,
            avatarUrl: player.avatarUrl,
            score: player.score,
            frameId: player.activeFrame,
            uid: player.id,
            radius: 24,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 64,
          child: Text(
            player.name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isMe ? Colors.white : Colors.white70,
              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (activeTitleItem != null)
          Text(
            '${activeTitleItem.imageUrl}',
            style: const TextStyle(fontSize: 10),
          ),
      ],
    );
  }
}
