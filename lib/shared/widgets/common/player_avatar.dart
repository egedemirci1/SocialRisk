import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Oyuncu avatar widget'ı — Fotoğraf veya baş harf gösterir.
/// Puan bazlı efekt desteği mevcut (🔥 alev / ❄️ buz / ✨ parıltı).
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.score = 0,
    this.radius = 24,
    this.showEffect = true,
    this.frameId,
  });

  final String displayName;
  final String? avatarUrl;
  final int score;
  final double radius;
  final bool showEffect;
  final String? frameId;

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

  @override
  Widget build(BuildContext context) {
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
            boxShadow: score >= 1500
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
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontSize: radius * 0.8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                    ),
                  )
                : null,
          ),
        ),

        // Satın Alınan Kozmetik Çerçeve (Frame)
        if (frameId != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: frameId == 'frame_fire'
                      ? AppColors.fire
                      : frameId == 'frame_ice'
                          ? AppColors.ice
                          : AppColors.primary,
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (frameId == 'frame_fire'
                            ? AppColors.fire
                            : frameId == 'frame_ice'
                                ? AppColors.ice
                                : AppColors.primary)
                        .withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),

        // Efekt emojisi
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
    );
  }
}
