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

  /// Çerçeve ID'sine göre uygun emoji ring'i oluşturur ve avatarın tam merkezine yerleştirir.
  Widget _buildCenteredEmojiRing(String frameId, double r) {
    final Map<String, String> frameEmojis = {
      'frame_flower': '🌸',
      'frame_ice': '❄️',
      'frame_fire': '🔥',
      'frame_shield': '🛡️',
      'frame_ivy': '🌿',
      'frame_neon': '⚡',
      'frame_stars': '⭐',
      'frame_lightning': '🌩️',
    };
    final emoji = frameEmojis[frameId];
    if (emoji == null) return const SizedBox.shrink();

    const int count = 10;
    final distance = r + 2;
    final emojiSize = r * 0.7;
    final ringSize = (distance + emojiSize / 2) * 2;
    final center = ringSize / 2;
    final avatarDiameter = r * 2;
    final offset = -(ringSize - avatarDiameter) / 2;

    return Positioned(
      left: offset,
      top: offset,
      child: IgnorePointer(
        child: SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(count, (index) {
              final angle = (index * 2 * math.pi) / count;
              final x = math.cos(angle) * distance;
              final y = math.sin(angle) * distance;

              return Positioned(
                left: center + x - emojiSize / 2,
                top: center + y - emojiSize / 2,
                child: SizedBox(
                  width: emojiSize,
                  height: emojiSize,
                  child: Center(
                    child: Transform.rotate(
                      angle: angle + math.pi / 2,
                      child: Text(
                        emoji,
                        style: TextStyle(
                          fontSize: emojiSize * 0.85,
                          height: 1.0,
                          shadows: [
                            Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
                          ],
                        ),
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

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
            backgroundImage: currentAvatarUrl != null
                ? NetworkImage(currentAvatarUrl)
                : null,
            child: currentAvatarUrl == null
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
          // Emoji ring — merkezlenmiş
          _buildCenteredEmojiRing(currentFrameId, radius),
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
