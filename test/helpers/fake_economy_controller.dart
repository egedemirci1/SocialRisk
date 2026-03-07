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

/// Çağrıları kaydeden controller; verify(...).called(...) yerine listeyi kontrol eder.
class SpyEconomyController extends EconomyController {
  final List<({String uid, String? cosmeticId})> setActiveFrameCalls = [];
  final List<({String uid, String? cosmeticId})> setActiveTitleCalls = [];
  final List<({String uid, String cosmeticId, int price})> buyCosmeticCalls = [];
  final List<({String uid, int points})> addPointsToWalletCalls = [];

  @override
  Future<void> setActiveFrame({
    required String uid,
    required String? cosmeticId,
  }) async {
    setActiveFrameCalls.add((uid: uid, cosmeticId: cosmeticId));
  }

  @override
  Future<void> setActiveTitle({
    required String uid,
    required String? cosmeticId,
  }) async {
    setActiveTitleCalls.add((uid: uid, cosmeticId: cosmeticId));
  }

  @override
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  }) async {
    buyCosmeticCalls.add((uid: uid, cosmeticId: cosmeticId, price: price));
  }

  @override
  Future<void> addPointsToWallet({
    required String uid,
    required int points,
  }) async {
    addPointsToWalletCalls.add((uid: uid, points: points));
  }
}
