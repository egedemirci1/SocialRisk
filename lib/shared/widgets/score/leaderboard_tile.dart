import 'package:flutter/material.dart';
import 'package:social_risk/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.playerName,
    required this.score,
    this.isCurrentPlayer = false,
    this.compact = false,
  });

  final int rank;
  final String playerName;
  final int score;
  final bool isCurrentPlayer;
  final bool compact;

  Color get _rankColor {
    switch (rank) {
      case 1:
        return AppColors.accent;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.white38;
    }
  }

  IconData? get _rankIcon {
    switch (rank) {
      case 1:
        return Icons.looks_one_rounded;
      case 2:
        return Icons.looks_two_rounded;
      case 3:
        return Icons.looks_3_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tilePaddingH = compact ? 12.0 : 16.0;
    final tilePaddingV = compact ? 12.0 : 14.0;
    final rankWidth = compact ? 30.0 : 36.0;
    final avatarSize = compact ? 34.0 : 40.0;
    final gap = compact ? 8.0 : 12.0;
    final nameFont = compact ? 14.0 : 15.0;
    final subFont = compact ? 10.0 : 11.0;
    final scoreFont = compact ? 18.0 : 20.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: isCurrentPlayer
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tilePaddingH,
          vertical: tilePaddingV,
        ),
        child: Row(
          children: [
            SizedBox(
              width: rankWidth,
              child: _rankIcon != null
                  ? Icon(
                      _rankIcon,
                      color: _rankColor,
                      size: compact ? 18 : 22,
                    )
                  : Text(
                      '$rank',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: _rankColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            SizedBox(width: gap),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevated,
              ),
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white38,
                    size: compact ? 18 : 22,
                  ),
                ),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    playerName,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isCurrentPlayer ? AppColors.primary : Colors.white,
                      fontSize: nameFont,
                      fontWeight:
                          isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCurrentPlayer)
                    Text(
                      AppLocalizations.of(context)!.you,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: subFont,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: compact ? 6 : 8),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: compact ? 54 : 64),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Text(
                      '$score',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: scoreFont,
                        fontWeight: FontWeight.w800,
                        color: _rankColor,
                      ),
                    ),
                    SizedBox(width: compact ? 3 : 4),
                    Text(
                      AppLocalizations.of(context)!.points,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white38,
                        fontSize: subFont,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
