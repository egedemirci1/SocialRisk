import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/category_constants.dart';

/// Görev kartı — Kategori, görev metni ve puan çarpanı. Renk/ikon CategoryConstants'tan.
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.category,
    required this.content,
    required this.points,
  });

  final String category;
  final String content;
  final int points;

  CategoryDefinition get _categoryDef => CategoryConstants.fallback(category);

  Color get _categoryColor => _categoryDef.color;

  IconData get _categoryIcon => _categoryDef.icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _categoryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _categoryColor.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kategori başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_categoryIcon, color: _categoryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  category.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _categoryColor,
                    letterSpacing: 1.5,),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Görev metni
            Text(
              content,
              style: AppTextStyles.displayMedium.copyWith(
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Çarpan badge
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$points puan',
                      style: AppTextStyles.titleSmall.copyWith(fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,),
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
