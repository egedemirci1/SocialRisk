import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Kategori tanımı — id, isim, ikon, renk. Tek kaynak (SSoT).
class CategoryDefinition {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// 8 sabit kategori + Özel. Tüm uygulama bu listeden okur.
class CategoryConstants {
  CategoryConstants._();

  static const List<CategoryDefinition> all = [
    CategoryDefinition(
      id: 'Fiziksel',
      name: 'Fiziksel',
      icon: Icons.fitness_center_rounded,
      color: AppColors.votePositive,
    ),
    CategoryDefinition(
      id: 'Bilgi',
      name: 'Bilgi',
      icon: Icons.lightbulb_outline_rounded,
      color: AppColors.accent,
    ),
    CategoryDefinition(
      id: 'Dijital',
      name: 'Dijital',
      icon: Icons.phone_android_rounded,
      color: AppColors.primary,
    ),
    CategoryDefinition(
      id: 'İtiraf',
      name: 'İtiraf',
      icon: Icons.psychology_rounded,
      color: AppColors.glow,
    ),
    CategoryDefinition(
      id: 'Zihinsel',
      name: 'Zihinsel',
      icon: Icons.psychology_alt_rounded,
      color: AppColors.ice,
    ),
    CategoryDefinition(
      id: 'Ahlaki',
      name: 'Ahlaki',
      icon: Icons.balance_rounded,
      color: AppColors.voteNeutral,
    ),
    CategoryDefinition(
      id: 'Görsel',
      name: 'Görsel',
      icon: Icons.theater_comedy_rounded,
      color: AppColors.ice,
    ),
    CategoryDefinition(
      id: 'Mahrem',
      name: 'Mahrem',
      icon: Icons.favorite_rounded,
      color: AppColors.fire,
    ),
    CategoryDefinition(
      id: 'Özel',
      name: 'Özel',
      icon: Icons.category_rounded,
      color: AppColors.primary,
    ),
  ];

  /// Sadece 8 sabit kategori (Özel hariç) — oda/oyun seçimi için.
  static List<CategoryDefinition> get defaultCategoriesOnly =>
      all.where((c) => c.id != 'Özel').toList();

  /// İsim listesi — GameConstants ve dropdown için.
  static List<String> get defaultCategoryNames =>
      defaultCategoriesOnly.map((c) => c.name).toList();

  /// Tüm isimler (Özel dahil) — task editor dropdown için.
  static List<String> get allCategoryNames => all.map((c) => c.name).toList();

  static CategoryDefinition? byId(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Bilinmeyen kategori için fallback (örn. Özel veya eski veri).
  static CategoryDefinition fallback(String name) {
    final found = byId(name);
    if (found != null) return found;
    return CategoryDefinition(
      id: name,
      name: name,
      icon: Icons.category_rounded,
      color: AppColors.primary,
    );
  }
}
