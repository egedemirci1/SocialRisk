import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/common/player_avatar.dart';
import '../../../auth/providers/user_provider.dart';
import '../../../economy/providers/economy_provider.dart';
import '../../../room/domain/room_entity.dart';

class PlayerSpotlight extends ConsumerWidget {
  const PlayerSpotlight({
    super.key,
    required this.player,
    required this.isMe,
    this.compact = false,
  });

  final PlayerEntity player;
  final bool isMe;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final veryShort = MediaQuery.sizeOf(context).height <= 686;
    final avatarRadius = veryShort ? 32.0 : (compact ? 38.0 : 48.0);
    final profileAsync = ref.watch(watchUserProfileProvider(player.id));
    final profile = profileAsync.value;
    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: veryShort ? 16 : (compact ? 22 : 32),
                spreadRadius: veryShort ? 3 : (compact ? 5 : 8),
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.1),
                blurRadius: veryShort ? 28 : (compact ? 42 : 64),
                spreadRadius: veryShort ? 6 : (compact ? 10 : 16),
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: veryShort ? 2.5 : (compact ? 3 : 4),
              ),
            ),
            child: PlayerAvatar(
              displayName: player.name,
              avatarUrl: player.avatarUrl,
              score: player.score,
              frameId: player.activeFrame,
              uid: player.id,
              radius: avatarRadius,
            ),
          ),
        ),
        SizedBox(height: veryShort ? 5 : (compact ? 8 : 12)),
        Text(
          isMe ? 'Senin Sıran!' : '${player.name} Oynuyor',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: veryShort ? 13 : (compact ? 15 : 18),
          ),
          textAlign: TextAlign.center,
        ),
        if (activeTitleItem != null)
          Padding(
            padding: EdgeInsets.only(top: veryShort ? 1 : (compact ? 2 : 4)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: veryShort ? 5 : (compact ? 6 : 8),
                vertical: veryShort ? 1.5 : (compact ? 2 : 3),
              ),
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
                  fontSize: veryShort ? 8 : (compact ? 9 : 11),
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        SizedBox(height: veryShort ? 2 : (compact ? 4 : 8)),
      ],
    );
  }
}
