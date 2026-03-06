import 'category_constants.dart';

class GameConstants {
  static const int minPlayers = 2;
  static const int maxPlayers = 8;

  static const int defaultTargetScore = 500;
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
  static Map<String, int> get defaultMarketValues {
    final map = <String, int>{};
    for (final c in CategoryConstants.all) {
      map[c.id] = c.id == 'Bilgi' ? 1 : 2;
    }
    return map;
  }

  /// Her seçimde çarpan bu kadar düşer
  static const int marketDecayAmount = 1;

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
}
