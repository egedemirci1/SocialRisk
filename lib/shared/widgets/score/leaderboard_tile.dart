import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Sıralama listesi öğesi — Oyuncu adı, sıra, puan.
class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.playerName,
    required this.score,
    this.isCurrentPlayer = false,
  });

  final int rank;
  final String playerName;
  final int score;
  final bool isCurrentPlayer;

  Color get _rankColor {
    switch (rank) {
      case 1:
        return AppColors.accent;
      case 2:
        return const Color(0xFFC0C0C0); // Gümüş
      case 3:
        return const Color(0xFFCD7F32); // Bronz
      default:
        return Colors.white38;
    }
  }

  String get _rankEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isCurrentPlayer
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isCurrentPlayer
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Sıra
              SizedBox(
                width: 36,
                child: rank <= 3
                    ? Text(
                        _rankEmoji,
                        style: const TextStyle(fontSize: 22),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        '$rank',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _rankColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
              const SizedBox(width: 12),

              // Avatar placeholder
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceElevated,
                ),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white38,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // İsim
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    if (isCurrentPlayer)
                      Text(
                        'Sen',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // Puan
              Text(
                '$score',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _rankColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'puan',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
