part of 'create_room_screen.dart';

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final verticalPadding = compact ? 6.0 : 8.0;
    final fontSize = compact ? 12.0 : 13.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10, width: 1.5),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.transparent,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.background : Colors.white54,
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            ),
            child: Center(child: Text(label)),
          ),
        ],
      ),
    );
  }
}

class _CreateRoomMetrics {
  const _CreateRoomMetrics({
    required this.isCompactWidth,
    required this.isCompactHeight,
    required this.outerHorizontalPadding,
    required this.outerVerticalPadding,
    required this.safeBottomSpacing,
    required this.contentMaxWidth,
    required this.cardPadding,
    required this.cardRadius,
    required this.titleFontSize,
    required this.sectionGapLarge,
    required this.sectionGap,
    required this.actionTopSpacing,
    required this.sectionPadding,
    required this.sectionRadius,
    required this.sectionIconSize,
    required this.inlineGap,
    required this.sectionTitleFontSize,
    required this.sectionInnerGap,
    required this.contentGap,
    required this.valueFontBase,
    required this.valueFontDelta,
    required this.sliderTrackHeight,
    required this.sliderLabelOffset,
    required this.sliderLabelHorizontalPadding,
    required this.helperFontSize,
    required this.infoBoxPadding,
    required this.infoBoxRadius,
    required this.infoIconSize,
    required this.infoTitleFontSize,
    required this.textTightGap,
    required this.bodyFontSize,
    required this.bodyLineHeight,
    required this.chipSpacing,
    required this.chipRunSpacing,
    required this.minCategoryChipWidth,
    required this.categoryChipHorizontalPadding,
    required this.categoryChipVerticalPadding,
    required this.categorySoonFontSize,
    required this.categoryFontSize,
  });

  final bool isCompactWidth;
  final bool isCompactHeight;
  final double outerHorizontalPadding;
  final double outerVerticalPadding;
  final double safeBottomSpacing;
  final double contentMaxWidth;
  final double cardPadding;
  final double cardRadius;
  final double titleFontSize;
  final double sectionGapLarge;
  final double sectionGap;
  final double actionTopSpacing;
  final double sectionPadding;
  final double sectionRadius;
  final double sectionIconSize;
  final double inlineGap;
  final double sectionTitleFontSize;
  final double sectionInnerGap;
  final double contentGap;
  final double valueFontBase;
  final double valueFontDelta;
  final double sliderTrackHeight;
  final double sliderLabelOffset;
  final double sliderLabelHorizontalPadding;
  final double helperFontSize;
  final double infoBoxPadding;
  final double infoBoxRadius;
  final double infoIconSize;
  final double infoTitleFontSize;
  final double textTightGap;
  final double bodyFontSize;
  final double bodyLineHeight;
  final double chipSpacing;
  final double chipRunSpacing;
  final double minCategoryChipWidth;
  final double categoryChipHorizontalPadding;
  final double categoryChipVerticalPadding;
  final double categorySoonFontSize;
  final double categoryFontSize;

  factory _CreateRoomMetrics.from(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final shortestSide = mediaQuery.size.shortestSide;
    final isCompactWidth = width < 390;
    final isCompactHeight = height < 780;
    final isVerySmall = shortestSide < 360 || height < 720;

    return _CreateRoomMetrics(
      isCompactWidth: isCompactWidth,
      isCompactHeight: isCompactHeight,
      outerHorizontalPadding: isCompactWidth ? 12 : 16,
      outerVerticalPadding: isCompactHeight ? 6 : 10,
      safeBottomSpacing: mediaQuery.viewPadding.bottom,
      contentMaxWidth: 560,
      cardPadding: isVerySmall ? 14 : 18,
      cardRadius: isCompactWidth ? 24 : 30,
      titleFontSize: isVerySmall ? 20 : 23,
      sectionGapLarge: isVerySmall ? 10 : 14,
      sectionGap: isVerySmall ? 8 : 10,
      actionTopSpacing: isVerySmall ? 12 : 16,
      sectionPadding: isVerySmall ? 8 : 10,
      sectionRadius: isCompactWidth ? 20 : 24,
      sectionIconSize: isCompactWidth ? 16 : 18,
      inlineGap: isVerySmall ? 6 : 8,
      sectionTitleFontSize: isVerySmall ? 14 : 15,
      sectionInnerGap: isVerySmall ? 8 : 10,
      contentGap: isVerySmall ? 8 : 10,
      valueFontBase: isVerySmall ? 14 : 16,
      valueFontDelta: isVerySmall ? 8 : 10,
      sliderTrackHeight: isVerySmall ? 4 : 5,
      sliderLabelOffset: isVerySmall ? 12 : 14,
      sliderLabelHorizontalPadding: isVerySmall ? 2 : 4,
      helperFontSize: isVerySmall ? 10 : 11,
      infoBoxPadding: isVerySmall ? 10 : 12,
      infoBoxRadius: isCompactWidth ? 14 : 16,
      infoIconSize: isCompactWidth ? 20 : 22,
      infoTitleFontSize: isVerySmall ? 13 : 14,
      textTightGap: isVerySmall ? 2 : 4,
      bodyFontSize: isVerySmall ? 11 : 12,
      bodyLineHeight: isVerySmall ? 1.2 : 1.3,
      chipSpacing: isVerySmall ? 6 : 8,
      chipRunSpacing: isVerySmall ? 6 : 8,
      minCategoryChipWidth: isVerySmall ? 78 : 90,
      categoryChipHorizontalPadding: isVerySmall ? 6 : 8,
      categoryChipVerticalPadding: isVerySmall ? 6 : 8,
      categorySoonFontSize: isVerySmall ? 9 : 10,
      categoryFontSize: isVerySmall ? 11 : 12,
    );
  }
}