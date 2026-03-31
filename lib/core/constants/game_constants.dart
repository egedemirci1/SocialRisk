import 'dart:math';

import 'category_constants.dart';

class GameConstants {
  static const int minPlayers = 2;
  static const int maxPlayers = 8;

  static const int defaultTargetScore = 250;
  static const int defaultMaxRounds = 10;

  static const int basePenalty = 50;

  static const Duration voteDuration = Duration(seconds: 15);
  static const Duration lobbyRefreshRate = Duration(seconds: 2);

  /// Varsayılan kategoriler — CategoryConstants'tan tek kaynak (SSoT)
  static List<String> get defaultCategories => CategoryConstants.defaultCategoryNames;

  /// Const varsayılan liste (constructor default param için; içerik defaultCategories ile aynı)
  static const List<String> defaultCategoriesConst = [
    'Fiziksel',
    'Bilgi',
    'Dijital',
    'İtiraf',
    'Zihinsel',
    'Ahlaki',
    'Görsel',
    'Mahrem',
  ];

  /// Zorluk seviyeleri
  static const List<String> defaultDifficulties = ['easy', 'medium', 'hard'];

  /// Her kategori×zorluk kombinasyonu için ön-yüklenen görev sayısı
  static const int taskPoolSizePerCombo = 5;

  // Faz 10: Ekonomi Modu sabitleri (8 kategori + Özel)
  static const int defaultEconomyBaseValue = 10;
  static const int economyPenaltyAmount = 2;
  static Map<String, int> get defaultMarketValues {
    final map = <String, int>{};
    for (final c in CategoryConstants.all) {
      map[c.id] = defaultEconomyBaseValue; // Tüm kategoriler 10 Taban Puanla başlar
    }
    return map;
  }

  /// Her seçimde çarpan bu kadar düşer
  static const int marketDecayAmount = 2;

  /// Ekonomi modu puan sınırları (depolanan değer 0–10; sıcak fırsat gösterimde 12)
  static const int minMarketValue = 0;
  static const int maxMarketValue = 10;

  /// Sıcak fırsat kategorisi için puan (Borsa modunda her tur 1 kategori)
  static const int hotCategoryBonus =
      defaultEconomyBaseValue + economyPenaltyAmount;
  static const int economyPenaltyValue =
      defaultEconomyBaseValue - economyPenaltyAmount;

  /// Bu kadar kez seçilince kategori kilitlenir
  static const int lockThreshold = 3;

  /// Kategorilerin seçim sayıları (başlangıç)
  static Map<String, int> get defaultPickCounts {
    final map = <String, int>{};
    for (final name in CategoryConstants.allCategoryNames) {
      map[name] = 0;
    }
    return map;
  }

  static int economyBaseValueForCategory({
    required String category,
    required int categoryCount,
    String? hotCategory,
    String? penalizedCategory,
  }) {
    if (hotCategory == category) return hotCategoryBonus;
    if (penalizedCategory == category) return economyPenaltyValue;
    return defaultEconomyBaseValue;
  }

  static String? economyPenaltyCategoryForNextTurn({
    required int categoryCount,
    required String? selectedCategory,
    required String? currentHotCategory,
  }) {
    if (selectedCategory == null) return null;
    if (selectedCategory == currentHotCategory) return null;
    return selectedCategory;
  }

  static String? pickEconomyHotCategory({
    required Iterable<String> categories,
    Iterable<String> excludedCategories = const [],
    Random? random,
  }) {
    final categoryList = categories.toList(growable: false);
    if (categoryList.isEmpty) return null;

    final excluded = excludedCategories.toSet();
    final candidates = categoryList
        .where((category) => !excluded.contains(category))
        .toList(growable: false);

    if (candidates.isEmpty) return null;
    final rng = random ?? Random();
    return candidates[rng.nextInt(candidates.length)];
  }

  static Map<String, int> buildEconomyTurnValues({
    required Iterable<String> categories,
    String? hotCategory,
    String? penalizedCategory,
  }) {
    final categoryList = categories.toList(growable: false);
    return {
      for (final category in categoryList)
        category: economyBaseValueForCategory(
          category: category,
          categoryCount: categoryList.length,
          hotCategory: hotCategory,
          penalizedCategory: penalizedCategory,
        ),
    };
  }

  static int economyResolvedStoredBaseValue({
    required String category,
    required Map<String, int> storedValues,
  }) {
    return storedValues[category] ?? defaultEconomyBaseValue;
  }
}
