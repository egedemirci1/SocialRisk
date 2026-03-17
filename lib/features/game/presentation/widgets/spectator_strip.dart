import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/common/player_avatar.dart';
import '../../../auth/providers/user_provider.dart';
import '../../../economy/providers/economy_provider.dart';
import '../../../room/domain/room_entity.dart';

class SpectatorStrip extends ConsumerWidget {
  const SpectatorStrip({
    super.key,
    required this.players,
    required this.currentPlayerId,
    this.myPlayerId,
    this.compact = false,
  });

  final List<PlayerEntity> players;
  final String currentPlayerId;
  final String? myPlayerId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spectators = players.where((p) => p.id != currentPlayerId).toList();
    if (spectators.isEmpty) return const SizedBox.shrink();

    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];
    final size = MediaQuery.sizeOf(context);
    final veryShort = size.height <= 686;
    final double stripHeight = ((veryShort && compact)
            ? (size.height * 0.075).clamp(48.0, 56.0)
            : (compact
                ? (size.height * 0.09).clamp(60.0, 74.0)
                : (size.height * 0.11).clamp(70.0, 90.0)))
        .toDouble();
    final spacing = veryShort ? 8.0 : (compact ? 10.0 : 16.0);

    return SizedBox(
      height: stripHeight,
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
          itemCount: spectators.length,
          separatorBuilder: (context, index) => SizedBox(width: spacing),
          itemBuilder: (context, index) {
            final player = spectators[index];
            final isMe = player.id == myPlayerId;

            return _SpectatorItem(
              player: player,
              isMe: isMe,
              cosmetics: cosmetics,
              compact: compact,
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
    required this.compact,
  });

  final PlayerEntity player;
  final bool isMe;
  final List cosmetics;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final veryShort = MediaQuery.sizeOf(context).height <= 686;
    final profileAsync = ref.watch(watchUserProfileProvider(player.id));
    final profile = profileAsync.value;
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return SizedBox(
      height: veryShort && compact ? 50 : (compact ? 58 : 74),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMe ? AppColors.primary : Colors.transparent,
                width: veryShort ? 1.2 : (compact ? 1.5 : 2),
              ),
            ),
            child: PlayerAvatar(
              displayName: player.name,
              avatarUrl: player.avatarUrl,
              score: player.score,
              frameId: player.activeFrame,
              uid: player.id,
              radius: veryShort ? 15 : (compact ? 17 : 24),
            ),
          ),
          SizedBox(height: veryShort ? 1 : (compact ? 2 : 3)),
          SizedBox(
            width: veryShort ? 46 : (compact ? 52 : 64),
            child: Text(
              player.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? Colors.white : Colors.white70,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                fontSize: veryShort ? 8 : (compact ? 9 : 11),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (activeTitleItem != null)
            Text(
              '${activeTitleItem.imageUrl}',
              style: TextStyle(fontSize: veryShort ? 7 : (compact ? 8 : 10)),
            ),
        ],
      ),
    );
  }
}
