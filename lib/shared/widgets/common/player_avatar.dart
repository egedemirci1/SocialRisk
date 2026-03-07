import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/user_provider.dart';
import 'custom_frame_painter.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

/// Oyuncu avatar widget'ı — Fotoğraf veya baş harf gösterir.
/// Puan bazlı efekt desteği mevcut (🔥 alev / ❄️ buz / ✨ parıltı).
class PlayerAvatar extends ConsumerWidget {
  const PlayerAvatar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.score = 0,
    this.radius = 24,
    this.showEffect = true,
    this.frameId,
    this.uid,
  });

  final String displayName;
  final String? avatarUrl;
  final int score;
  final double radius;
  final bool showEffect;
  final String? frameId;
  final String? uid;

  /// Puan aralığına göre efekt belirle
  String? get _effect {
    if (!showEffect || score == 0) return null;
    if (score >= 3000) return '🔥';
    if (score >= 1500) return '✨';
    if (score >= 500) return '❄️';
    return null;
  }

  Color get _borderColor {
    if (score >= 3000) return AppColors.fire;
    if (score >= 1500) return AppColors.accent;
    if (score >= 500) return AppColors.ice;
    return Colors.transparent;
  }

  // CustomFramePainter artık çerçeveler için kullanılıyor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? currentFrameId = frameId;
    String? currentAvatarUrl = avatarUrl;

    if (uid != null) {
      final userAsync = ref.watch(watchUserProfileProvider(uid!));
      if (userAsync.value != null) {
        if (userAsync.value!.activeFrame != null) {
          currentFrameId = userAsync.value!.activeFrame;
        }
        if (userAsync.value!.avatarUrl != null && userAsync.value!.avatarUrl!.isNotEmpty) {
          currentAvatarUrl = userAsync.value!.avatarUrl;
        }
      }
    }

    final useAvatarImage = currentAvatarUrl != null && currentAvatarUrl.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar çerçevesi
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColor,
              width: score >= 500 ? 2.5 : 0,
            ),
            boxShadow: currentFrameId != null 
              ? [
                  BoxShadow(
                    color: (currentFrameId == 'frame_fire'
                            ? AppColors.fire
                            : currentFrameId == 'frame_ice'
                            ? AppColors.ice
                            : currentFrameId == 'frame_flower'
                            ? Colors.pinkAccent
                            : currentFrameId == 'frame_shield'
                            ? Colors.indigoAccent
                            : currentFrameId == 'frame_ivy'
                            ? Colors.green
                            : currentFrameId == 'frame_neon'
                            ? Colors.cyanAccent
                            : currentFrameId == 'frame_stars'
                            ? const Color(0xFFD4AF37)
                            : currentFrameId == 'frame_lightning'
                            ? Colors.lightBlueAccent
                            : AppColors.primary)
                        .withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ] : score >= 1500
                ? [
                    BoxShadow(
                      color: _borderColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.surfaceElevated,
            backgroundImage: useAvatarImage
                ? NetworkImage(currentAvatarUrl!)
                : null,
            child: !useAvatarImage
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: AppTextStyles.titleSmall.copyWith(fontSize: radius * 0.8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,),
                  )
                : null,
          ),
        ),

        // Satın Alınan Kozmetik Çerçeve (Frame) - Görsel Efekt
        if (currentFrameId != null) ...[
          // Renkli aura / glow border
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentFrameId == 'frame_fire'
                        ? AppColors.fire.withValues(alpha: 0.8)
                        : currentFrameId == 'frame_ice'
                        ? AppColors.ice.withValues(alpha: 0.8)
                        : currentFrameId == 'frame_flower'
                        ? Colors.pinkAccent.withValues(alpha: 0.8)
                        : currentFrameId == 'frame_shield'
                        ? Colors.indigoAccent.withValues(alpha: 0.8)
                        : currentFrameId == 'frame_ivy'
                        ? Colors.green.withValues(alpha: 0.8)
                        : currentFrameId == 'frame_neon'
                        ? Colors.cyanAccent.withValues(alpha: 0.8)
                        : currentFrameId == 'frame_stars'
                        ? const Color(0xFFD4AF37).withValues(alpha: 0.8)
                        : currentFrameId == 'frame_lightning'
                        ? Colors.lightBlueAccent.withValues(alpha: 0.8)
                        : AppColors.primary,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
          // Doğal çizimli özel frame painter
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: CustomFramePainter(frameId: currentFrameId, radius: radius),
              ),
            ),
          ),
        ],

        // Efekt emojisi
        if (_effect != null)
          Positioned(
            right: -4,
            top: -4,
            child: Text(_effect!, style: TextStyle(fontSize: radius * 0.55)),
          ),
      ],
    );
  }
}
