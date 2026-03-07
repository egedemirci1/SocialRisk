import 'package:social_risk/features/economy/providers/economy_provider.dart';

/// Test için EconomyController — alışveriş ve cüzdan no-op.
class FakeEconomyController extends EconomyController {
  @override
  Future<void> addPointsToWallet({
    required String uid,
    required int points,
  }) async {}

  @override
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  }) async {}

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
}
