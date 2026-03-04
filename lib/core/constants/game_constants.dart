class GameConstants {
  static const int minPlayers = 2;
  static const int maxPlayers = 8;

  static const int defaultTargetScore = 500;
  static const int defaultMaxRounds = 10;

  static const int basePenalty = 50;

  static const Duration voteDuration = Duration(seconds: 15);
  static const Duration lobbyRefreshRate = Duration(seconds: 2);

  /// Varsayılan kategoriler — tek kaynak (SSoT)
  static const List<String> defaultCategories = [
    'Cesaret',
    'İtiraf',
    'Taklit',
    'Sosyal Medya',
    'Fiziksel',
    'Bilgi',
  ];

  /// Zorluk seviyeleri
  static const List<String> defaultDifficulties = ['easy', 'medium', 'hard'];

  /// Her kategori×zorluk kombinasyonu için ön-yüklenen görev sayısı
  static const int taskPoolSizePerCombo = 5;

  // Faz 10: Ekonomi Modu sabitleri
  static const Map<String, int> defaultMarketValues = {
    'Cesaret': 3,
    'İtiraf': 3,
    'Taklit': 2,
    'Sosyal Medya': 2,
    'Fiziksel': 2,
    'Bilgi': 1,
  };

  /// Her seçimde çarpan bu kadar düşer
  static const int marketDecayAmount = 1;

  /// Bu kadar kez seçilince kategori kilitlenir
  static const int lockThreshold = 3;

  /// Kategorilerin seçim sayıları (başlangıç)
  static const Map<String, int> defaultPickCounts = {
    'Cesaret': 0,
    'İtiraf': 0,
    'Taklit': 0,
    'Sosyal Medya': 0,
    'Fiziksel': 0,
    'Bilgi': 0,
  };
}
