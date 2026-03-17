import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/category_constants.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.category,
    required this.content,
    required this.points,
    this.compact = false,
  });

  final String category;
  final String content;
  final int points;
  final bool compact;

  CategoryDefinition get _categoryDef => CategoryConstants.fallback(category);

  Color get _categoryColor => _categoryDef.color;

  IconData get _categoryIcon => _categoryDef.icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dense = constraints.maxHeight < 260 || constraints.maxWidth < 280;
        final padding = dense ? 10.0 : (compact ? 14.0 : 22.0);
        final titleFont = compact ? 12.0 : 13.0;
        final badgeFont = compact ? 12.0 : 14.0;
        final borderRadius = compact ? 16.0 : 20.0;
        final topGap = dense ? 8.0 : (compact ? 10.0 : 16.0);
        final bottomGap = dense ? 8.0 : (compact ? 12.0 : 18.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: _categoryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _categoryColor.withValues(alpha: 0.15),
                blurRadius: compact ? 18 : 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _categoryIcon,
                      color: _categoryColor,
                      size: compact ? 18 : 20,
                    ),
                    SizedBox(width: compact ? 6 : 8),
                    Flexible(
                      child: Text(
                        category.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: titleFont,
                          fontWeight: FontWeight.w700,
                          color: _categoryColor,
                          letterSpacing: compact ? 1.1 : 1.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: topGap),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, textConstraints) {
                      final contentFont = _fitContentFontSize(
                        context: context,
                        text: content,
                        maxWidth: textConstraints.maxWidth,
                        maxHeight: textConstraints.maxHeight,
                        maxFontSize: dense ? 18.0 : (compact ? 20.0 : 24.0),
                        minFontSize: 5.0,
                      );

                      return Center(
                        child: Text(
                          content,
                          style: AppTextStyles.displayMedium.copyWith(
                            color: Colors.white,
                            height: dense ? 1.08 : (compact ? 1.16 : 1.22),
                            fontSize: contentFont,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: bottomGap),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(compact ? 16 : 20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 12 : 16,
                      vertical: dense ? 5 : (compact ? 6 : 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: AppColors.accent,
                          size: compact ? 16 : 18,
                        ),
                        SizedBox(width: compact ? 3 : 4),
                        Text(
                          '$points puan',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: badgeFont,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
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
      },
    );
  }

  double _fitContentFontSize({
    required BuildContext context,
    required String text,
    required double maxWidth,
    required double maxHeight,
    required double maxFontSize,
    required double minFontSize,
  }) {
    if (maxWidth <= 0 || maxHeight <= 0) return minFontSize;

    final textDirection = Directionality.of(context);
    var low = minFontSize;
    var high = maxFontSize;
    var best = minFontSize;

    while ((high - low) > 0.25) {
      final mid = (low + high) / 2;
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: AppTextStyles.displayMedium.copyWith(
            fontSize: mid,
            height: compact ? 1.16 : 1.22,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: textDirection,
      )..layout(maxWidth: maxWidth);

      final fits = painter.height <= maxHeight;
      if (fits) {
        best = mid;
        low = mid;
      } else {
        high = mid;
      }
    }

    return best;
  }
}
