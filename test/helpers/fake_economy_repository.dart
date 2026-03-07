import 'package:social_risk/features/economy/domain/cosmetic_item_entity.dart';
import 'package:social_risk/features/economy/domain/economy_repository.dart';

/// Test için EconomyRepository — tüm işlemler no-op veya sahte veri.
class FakeEconomyRepository implements EconomyRepository {
  FakeEconomyRepository({
    this.cosmetics = const [],
    this.buyThrows = false,
  });

  final List<CosmeticItemEntity> cosmetics;
  final bool buyThrows;

  @override
  Future<void> addPointsToWallet({
    required String uid,
    required int points,
  }) async {}

  @override
  Future<void> distributeRewards(Map<String, int> playerRewards) async {}

  @override
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  }) async {
    if (buyThrows) {
      throw Exception('Yetersiz bakiye');
    }
  }

  @override
  Future<void> setActiveFrame({
    required String uid,
    required String? cosmeticId,
  }) async {}

  @override
  Future<void> setActiveTitle({
    required String uid,
    required String? cosmeticId,
  }) async {}

  @override
  Future<List<CosmeticItemEntity>> fetchCosmetics() async => List.from(cosmetics);
}
