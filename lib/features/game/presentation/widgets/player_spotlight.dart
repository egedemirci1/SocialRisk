import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/common/player_avatar.dart';
import '../../../room/domain/room_entity.dart';

/// Oyun alanında o anda sırası olan oyuncuyu vurgulayan widget.
class PlayerSpotlight extends StatelessWidget {
  final PlayerEntity player;
  final bool isMe;

  const PlayerSpotlight({
    super.key,
    required this.player,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Spotlight glow effect
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 32,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.1),
                blurRadius: 64,
                spreadRadius: 16,
              ),
            ],
          ),
          child: DecoratedBox(
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(
                 color: AppColors.primary,
                 width: 4,
               ),
             ),
             child: PlayerAvatar(
               displayName: player.name,
               avatarUrl: player.avatarUrl,
               score: player.score,
               frameId: player.activeFrame,
               radius: 48,
             ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isMe ? 'Senin Sıran!' : '${player.name} oynuyor',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
