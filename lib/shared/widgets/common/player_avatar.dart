import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/user_provider.dart';
import 'custom_frame_painter.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

/// Oyuncu avatar widget'i - Fotograf veya bas harf gosterir.
/// Puan bazli efekt destegi mevcut.
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

  static double _frameExtent(double radius) =>
      (radius * 0.036).clamp(0.8, 2.7);

  static double _frameStrokeWidth(double radius) =>
      (radius * 0.022).clamp(0.8, 1.6);

  static double _frameGlowBlur(double radius) =>
      (radius * 0.11).clamp(1.8, 5.4);

  static double _frameGlowSpread(double radius) =>
      (radius * 0.027).clamp(0.2, 1.1);

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? currentFrameId = frameId;
    String? currentAvatarUrl = avatarUrl;

    if (uid != null) {
      final userAsync = ref.watch(watchUserProfileProvider(uid!));
      final profile = userAsync.value;
      if (profile != null) {
        if (profile.activeFrame != null) {
          currentFrameId = profile.activeFrame;
        }
        if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
          currentAvatarUrl = profile.avatarUrl;
        }
      }
    }

    final useAvatarImage =
        currentAvatarUrl != null && currentAvatarUrl.isNotEmpty;
    final hasFrame = currentFrameId != null && currentFrameId.isNotEmpty;
    final frameExtent = hasFrame ? _frameExtent(radius) : 0.0;
    final frameStrokeWidth = _frameStrokeWidth(radius);
    final frameGlowBlur = _frameGlowBlur(radius);
    final frameGlowSpread = _frameGlowSpread(radius);
    final avatarDiameter = radius * 2;
    final totalDiameter = avatarDiameter + (frameExtent * 2);

    return SizedBox(
      width: totalDiameter,
      height: totalDiameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _borderColor,
                    width: score >= 500 ? 2.5 : 0,
                  ),
                  boxShadow: hasFrame
                      ? [
                          BoxShadow(
                            color: _frameColor(currentFrameId ?? '')
                                .withValues(alpha: 0.5),
                            blurRadius: frameGlowBlur,
                            spreadRadius: frameGlowSpread,
                          ),
                        ]
                      : score >= 1500
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
                  backgroundImage:
                      useAvatarImage ? NetworkImage(currentAvatarUrl ?? '') : null,
                  child: !useAvatarImage
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: radius * 0.8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          if (hasFrame) ...[
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _frameColor(currentFrameId ?? '').withValues(alpha: 0.8),
                      width: frameStrokeWidth,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: CustomFramePainter(
                    frameId: currentFrameId ?? '',
                    radius: radius,
                  ),
                ),
              ),
            ),
          ],
          if (_effect != null)
            Positioned(
              right: -4,
              top: -4,
              child: Text(
                _effect!,
                style: TextStyle(fontSize: radius * 0.55),
              ),
            ),
        ],
      ),
    );
  }

  Color _frameColor(String frame) {
    switch (frame) {
      case 'frame_fire':
        return AppColors.fire;
      case 'frame_ice':
        return AppColors.ice;
      case 'frame_flower':
        return Colors.pinkAccent;
      case 'frame_shield':
        return Colors.indigoAccent;
      case 'frame_ivy':
        return Colors.green;
      case 'frame_neon':
        return Colors.cyanAccent;
      case 'frame_stars':
        return const Color(0xFFD4AF37);
      case 'frame_lightning':
        return Colors.lightBlueAccent;
      default:
        return AppColors.primary;
    }
  }
}
