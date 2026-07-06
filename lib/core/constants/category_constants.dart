import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Kategori tanımı — id, isim, ikon, renk. Tek kaynak (SSoT).
class CategoryDefinition {
  final String id;
  final String name;
  final String nameEn;
  final IconData icon;
  final Color color;

  const CategoryDefinition({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  String localizedName(String languageCode) {
    return languageCode == 'en' ? nameEn : name;
  }
}

/// 8 sabit kategori + Özel. Tüm uygulama bu listeden okur.
class CategoryConstants {
  CategoryConstants._();

  /// Özel / custom deck kategori kimliği (encoding-safe tek kaynak).
  static const String customCategoryId = 'Özel';

  static const List<CategoryDefinition> all = [
    CategoryDefinition(
      id: 'Fiziksel',
      name: 'Fiziksel',
      nameEn: 'Physical',
      icon: Icons.fitness_center_rounded,
      color: AppColors.votePositive, // Zümrüt Yeşili
    ),
    CategoryDefinition(
      id: 'Bilgi',
      name: 'Bilgi',
      nameEn: 'Knowledge',
      icon: Icons.lightbulb_outline_rounded,
      color: AppColors.categoryKnowledge, // Koyu Turkuaz
    ),
    CategoryDefinition(
      id: 'Dijital',
      name: 'Dijital',
      nameEn: 'Digital',
      icon: Icons.phone_android_rounded,
      color: AppColors.categoryDigital, // Koyu Pembe/Mor
    ),
    CategoryDefinition(
      id: 'İtiraf',
      name: 'İtiraf',
      nameEn: 'Confession',
      icon: Icons.psychology_rounded,
      color: AppColors.voteNeutral, // Koyu Amber
    ),
    CategoryDefinition(
      id: 'Zihinsel',
      name: 'Zihinsel',
      nameEn: 'Mental',
      icon: Icons.psychology_alt_rounded,
      color: AppColors.ice, // Güçlü Mavi
    ),
    CategoryDefinition(
      id: 'Ahlaki',
      name: 'Ahlaki',
      nameEn: 'Moral',
      icon: Icons.balance_rounded,
      color: AppColors.glow, // Altın Sarısı
    ),
    CategoryDefinition(
      id: 'Görsel',
      name: 'Görsel',
      nameEn: 'Visual',
      icon: Icons.theater_comedy_rounded,
      color: AppColors.categoryVisual, // Derin Mor
    ),
    CategoryDefinition(
      id: 'Mahrem',
      name: 'Mahrem',
      nameEn: 'Private',
      icon: Icons.favorite_rounded,
      color: AppColors.fire, // Koyu Kırmızı
    ),
    CategoryDefinition(
      id: 'Özel',
      name: 'Özel İçerik',
      nameEn: 'Custom Content',
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
      nameEn: name,
      icon: Icons.category_rounded,
      color: AppColors.primary,
    );
  }
}
