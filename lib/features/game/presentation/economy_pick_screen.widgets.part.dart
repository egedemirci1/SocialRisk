part of 'economy_pick_screen.dart';

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.currentValue,
    required this.defaultValue,
    required this.isHotCategory,
    required this.isLocked,
    required this.isPickable,
    required this.onTap,
    required this.compact,
  });

  final String category;
  final int currentValue;
  final int defaultValue;
  final bool isHotCategory;
  final bool isLocked;
  final bool isPickable;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 12.0 : 16.0;
    final titleSize = compact ? 14.0 : 16.0;
    final valueSize = compact ? 18.0 : 20.0;
    final helperSize = compact ? 10.0 : 12.0;

    return GestureDetector(
      onTap: isPickable ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
          border: Border.all(
            color: isPickable
                ? AppColors.accent.withValues(alpha: 0.3)
                : Colors.white10,
          ),
        ),
        child: Stack(
          children: [
            if (isLocked)
              Center(
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white10,
                  size: compact ? 28 : 32,
                ),
              ),
            if (!isLocked && isHotCategory)
              Positioned(
                top: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.orange,
                      size: compact ? 16 : 18,
                    ),
                    Text(
                      AppLocalizations.of(context)!.hotDeal,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.orange,
                        fontSize: compact ? 6 : 7,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            // Extra top padding so hot deal badge never overlaps category name
            Opacity(
              opacity: isLocked ? 0.2 : 1.0,
              child: Padding(
                padding: EdgeInsets.only(
                  top: (!isLocked && isHotCategory) ? (compact ? 24.0 : 28.0) : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                    CategoryConstants.byId(category)?.localizedName(LocaleProvider.of(context).languageCode).toUpperCase() ?? category.toUpperCase(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: compact ? 0.6 : 1,
                      fontSize: titleSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currentValue',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: currentValue < defaultValue
                              ? AppColors.primary
                              : AppColors.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: valueSize,
                        ),
                      ),
                      if (currentValue < defaultValue) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.trending_down_rounded,
                          color: AppColors.primary,
                          size: compact ? 12 : 14,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: compact ? 2 : 4),
                  Text(
                    AppLocalizations.of(context)!.basePoint,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white24,
                      fontSize: helperSize,
                    ),
                    textAlign: TextAlign.center,
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

class _EconomyPickMetrics {
  const _EconomyPickMetrics({
    required this.isCompact,
    required this.screenPadding,
    required this.sectionGap,
    required this.sectionGapLarge,
    required this.inlineGap,
    required this.textGap,
    required this.titleFontSize,
    required this.titleLetterSpacing,
    required this.infoPadding,
    required this.infoRadius,
    required this.infoIconSize,
    required this.infoTitleFontSize,
    required this.helperFontSize,
    required this.helperIconSize,
    required this.gridSpacing,
    required this.singleColumnAspectRatio,
    required this.doubleColumnAspectRatio,
  });

  final bool isCompact;
  final double screenPadding;
  final double sectionGap;
  final double sectionGapLarge;
  final double inlineGap;
  final double textGap;
  final double titleFontSize;
  final double titleLetterSpacing;
  final double infoPadding;
  final double infoRadius;
  final double infoIconSize;
  final double infoTitleFontSize;
  final double helperFontSize;
  final double helperIconSize;
  final double gridSpacing;
  final double singleColumnAspectRatio;
  final double doubleColumnAspectRatio;

  factory _EconomyPickMetrics.from(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 390 || size.height < 700;
    final isTiny = size.height < 680;

    return _EconomyPickMetrics(
      isCompact: isCompact,
      screenPadding: isTiny ? 12 : (isCompact ? 16 : 24),
      sectionGap: isTiny ? 8 : (isCompact ? 12 : 20),
      sectionGapLarge: isTiny ? 12 : (isCompact ? 18 : 28),
      inlineGap: isTiny ? 6 : (isCompact ? 10 : 12),
      textGap: isCompact ? 6 : 8,
      titleFontSize: isTiny ? 14 : (isCompact ? 16 : 20),
      titleLetterSpacing: isCompact ? 1.0 : 2,
      infoPadding: isTiny ? 12 : (isCompact ? 14 : 18),
      infoRadius: isCompact ? 10 : 14,
      infoIconSize: isTiny ? 20 : (isCompact ? 24 : 28),
      infoTitleFontSize: isTiny ? 13 : (isCompact ? 14 : 16),
      helperFontSize: isCompact ? 11 : 12,
      helperIconSize: isCompact ? 14 : 18,
      gridSpacing: isTiny ? 8 : (isCompact ? 12 : 16),
      singleColumnAspectRatio: isTiny ? 3.5 : (isCompact ? 3.0 : 2.5),
      // Miktar yassı tutularak tüm cihazlarda scrollsuz görünüm hedefleniyor
      doubleColumnAspectRatio: isTiny ? 1.6 : (isCompact ? 1.45 : 1.35),
    );
  }
}