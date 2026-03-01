import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/common/player_avatar.dart';
import '../../../room/domain/room_entity.dart';

/// Oyun ekranındaki diğer oyuncuları küçük avatarlarla gösteren şerit.
class SpectatorStrip extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Sadece sırası olmayan seyircileri göster
    final spectators = players.where((p) => p.id != currentPlayerId).toList();

    if (spectators.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 80,
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
                    radius: 24,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: Text(
                    player.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isMe ? Colors.white : Colors.white70,
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
