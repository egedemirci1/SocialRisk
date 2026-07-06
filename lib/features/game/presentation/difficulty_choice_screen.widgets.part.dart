part of 'difficulty_choice_screen.dart';

class _DifficultyLayoutMetrics {
  const _DifficultyLayoutMetrics({
    required this.contentWidth,
    required this.horizontalPadding,
    required this.topGap,
    required this.sectionGap,
    required this.bottomGap,
    required this.categoryHeight,
    required this.categoryHorizontalPadding,
    required this.categoryVerticalPadding,
    required this.categoryRadius,
    required this.categoryFontSize,
    required this.categoryLetterSpacing,
    required this.heroHeight,
    required this.cardGap,
    required this.cardRadius,
    required this.heroHeaderPadding,
    required this.heroHorizontalPadding,
    required this.heroVerticalPadding,
    required this.heroLetterSpacing,
    required this.heroHeaderFontSize,
    required this.heroTitleFontSize,
    required this.heroSubtitleFontSize,
    required this.heroSubtitleGap,
    required this.hideHeroSubtitle,
    required this.waitingVerticalPadding,
    required this.waitingGap,
    required this.loaderSize,
    required this.difficultyCardRadius,
    required this.difficultyCardPadding,
    required this.cardTitleFontSize,
    required this.cardSubtitleFontSize,
    required this.cardSubtitleGap,
    required this.multiplierGap,
    required this.multiplierHorizontalPadding,
    required this.multiplierVerticalPadding,
    required this.multiplierRadius,
    required this.multiplierFontSize,
  });

  final double contentWidth;
  final double horizontalPadding;
  final double topGap;
  final double sectionGap;
  final double bottomGap;
  final double categoryHeight;
  final double categoryHorizontalPadding;
  final double categoryVerticalPadding;
  final double categoryRadius;
  final double categoryFontSize;
  final double categoryLetterSpacing;
  final double heroHeight;
  final double cardGap;
  final double cardRadius;
  final double heroHeaderPadding;
  final double heroHorizontalPadding;
  final double heroVerticalPadding;
  final double heroLetterSpacing;
  final double heroHeaderFontSize;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroSubtitleGap;
  final bool hideHeroSubtitle;
  final double waitingVerticalPadding;
  final double waitingGap;
  final double loaderSize;
  final double difficultyCardRadius;
  final double difficultyCardPadding;
  final double cardTitleFontSize;
  final double cardSubtitleFontSize;
  final double cardSubtitleGap;
  final double multiplierGap;
  final double multiplierHorizontalPadding;
  final double multiplierVerticalPadding;
  final double multiplierRadius;
  final double multiplierFontSize;

  factory _DifficultyLayoutMetrics.from(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final short = height < 700;
    final medium = height < 820;

    return _DifficultyLayoutMetrics(
      contentWidth: min(max(width * 0.86, 320.0), width),
      horizontalPadding: width < 380 ? 12 : 20,
      topGap: short ? 8 : 20,
      sectionGap: short ? 10 : 24,
      bottomGap: short ? 10 : 18,
      categoryHeight: short ? 52 : 66,
      categoryHorizontalPadding: short ? 16 : 22,
      categoryVerticalPadding: short ? 10 : 12,
      categoryRadius: short ? 20 : 24,
      categoryFontSize: short ? 17 : 20,
      categoryLetterSpacing: short ? 1.2 : 2,
      heroHeight: short ? height * 0.20 : height * 0.24,
      cardGap: short ? 8 : 16,
      cardRadius: short ? 16 : 20,
      heroHeaderPadding: short ? 12 : 16,
      heroHorizontalPadding: short ? 16 : 24,
      heroVerticalPadding: short ? 14 : 24,
      heroLetterSpacing: short ? 1.1 : 2,
      heroHeaderFontSize: short ? 18 : 22,
      heroTitleFontSize: short ? 22 : 28,
      heroSubtitleFontSize: short ? 13 : 15,
      heroSubtitleGap: short ? 6 : 8,
      hideHeroSubtitle: height < 640,
      waitingVerticalPadding: short ? 20 : 32,
      waitingGap: short ? 18 : 32,
      loaderSize: short ? 28 : 36,
      difficultyCardRadius: short ? 14 : 12,
      difficultyCardPadding: short ? 16 : (medium ? 20 : 24),
      cardTitleFontSize: short ? 18 : 22,
      cardSubtitleFontSize: short ? 14 : 16,
      cardSubtitleGap: short ? 8 : 12,
      multiplierGap: short ? 6 : 8,
      multiplierHorizontalPadding: short ? 12 : 16,
      multiplierVerticalPadding: short ? 6 : 8,
      multiplierRadius: short ? 8 : 10,
      multiplierFontSize: short ? 18 : 20,
    );
  }
}