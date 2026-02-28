import 'cosmetic_item_entity.dart';

abstract class EconomyRepository {
  /// Oyun sonunda oyuncunun cüzdanına puan ekler (veya ceza varsa çıkarır).
  Future<void> addPointsToWallet({
    required String uid,
    required int points,
  });

  /// Oyuncu kozmetik bir eşya (çerçeve vb.) satın aldığında cüzdanından puan düşer ve envantere ekler.
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  });

  /// Aktif kozmetik çerçevesini değiştirir.
  Future<void> setActiveFrame({
    required String uid,
    required String? cosmeticId,
  });

  /// Mağazadaki tüm kozmetik çerçeveleri/ürünleri getirir.
  Future<List<CosmeticItemEntity>> fetchCosmetics();
}
