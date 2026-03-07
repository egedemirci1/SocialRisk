import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/common/player_avatar.dart';
import '../../../auth/providers/user_provider.dart';
import '../../../economy/providers/economy_provider.dart';
import '../../../room/domain/room_entity.dart';

/// Oyun alanında o anda sırası olan oyuncuyu vurgulayan widget.
class PlayerSpotlight extends ConsumerWidget {
  final PlayerEntity player;
  final bool isMe;

  const PlayerSpotlight({
    super.key,
    required this.player,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Canlı profil — ünvan
    final profileAsync = ref.watch(watchUserProfileProvider(player.id));
    final profile = profileAsync.value;
    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

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
               uid: player.id,
               radius: 48,
             ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isMe ? 'Senin Sıran!' : '${player.name} oynuyor',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (activeTitleItem != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                '${activeTitleItem.imageUrl} ${activeTitleItem.name}',
                style: AppTextStyles.specialHeading.copyWith(
                  color: const Color(0xFFD4AF37),
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
