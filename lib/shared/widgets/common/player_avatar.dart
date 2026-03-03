import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/user_provider.dart';

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

  /// Emojilerle avatarın etrafında taç/çerçeve efekti yaratan yardımcı fonksiyon
  Widget _buildEmojiRing(String emoji, double r) {
    const int count = 10;
    final distance = r + 2; 
    final ringSize = (distance + r * 0.4) * 2;
    
    return IgnorePointer(
      child: SizedBox(
        width: ringSize,
        height: ringSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const SizedBox.shrink(),
            ...List.generate(count, (index) {
              final angle = (index * 2 * math.pi) / count;
              final x = math.cos(angle) * distance;
              final y = math.sin(angle) * distance;
              
              return Positioned(
                left: r + x - (r * 0.4),
                top: r + y - (r * 0.4),
                child: Transform.rotate(
                  angle: angle + math.pi / 2,
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: r * 0.7,
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? currentFrameId = frameId;

    if (uid != null) {
      final userAsync = ref.watch(watchUserProfileProvider(uid!));
      if (userAsync.value != null && userAsync.value!.activeFrame != null) {
        currentFrameId = userAsync.value!.activeFrame;
      }
    }

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
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      fontSize: radius * 0.8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                    ),
                  )
                : null,
          ),
        ),

        // Satın Alınan Kozmetik Çerçeve (Frame) - Görsel Efekt
        if (currentFrameId != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Arka plandaki renkli aura / glow
                  Container(
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
                  // Üstteki emojiler (çiçek, kalkan vs)
                  if (currentFrameId == 'frame_flower') _buildEmojiRing('🌸', radius),
                  if (currentFrameId == 'frame_ice') _buildEmojiRing('❄️', radius),
                  if (currentFrameId == 'frame_fire') _buildEmojiRing('🔥', radius),
                  if (currentFrameId == 'frame_shield') _buildEmojiRing('🛡️', radius),
                  if (currentFrameId == 'frame_ivy') _buildEmojiRing('🌿', radius),
                  if (currentFrameId == 'frame_neon') _buildEmojiRing('⚡', radius),
                  if (currentFrameId == 'frame_stars') _buildEmojiRing('⭐', radius),
                  if (currentFrameId == 'frame_lightning') _buildEmojiRing('🌩️', radius),
                ],
              ),
            ),
          ),

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
