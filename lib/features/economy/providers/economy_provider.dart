import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/economy_repository.dart';
import '../domain/cosmetic_item_entity.dart';
import '../data/firebase_economy_source.dart';

part 'economy_provider.g.dart';

@Riverpod(keepAlive: true)
EconomyRepository economyRepository(Ref ref) {
  return FirebaseEconomySource();
}

@Riverpod(keepAlive: true)
Future<List<CosmeticItemEntity>> fetchCosmetics(Ref ref) {
  return ref.watch(economyRepositoryProvider).fetchCosmetics();
}

@Riverpod(keepAlive: true)
class EconomyController extends _$EconomyController {
  @override
  FutureOr<void> build() {}

  /// Puan ekle/çıkar (oyun sonu çağrılır)
  Future<void> addPointsToWallet({
    required String uid,
    required int points,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(economyRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.addPointsToWallet(uid: uid, points: points),
    );
    // Not: Hata durumunda UI'da AsyncValue.when veya state.hasError ile yakalanmalı.
    // throw state.error! kaldırılarak UI çökmesi önlendi.
  }

  /// Yeni ürün al
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(economyRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.buyCosmetic(uid: uid, cosmeticId: cosmeticId, price: price),
    );
    // Not: throw state.error! kaldırılarak UI çökmesi önlendi.
  }

  /// Aktif eşyayı değiştir
  Future<void> setActiveFrame({
    required String uid,
    required String? cosmeticId,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(economyRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.setActiveFrame(uid: uid, cosmeticId: cosmeticId),
    );
  }

  /// Aktif unvanı değiştir
  Future<void> setActiveTitle({
    required String uid,
    required String? cosmeticId,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(economyRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.setActiveTitle(uid: uid, cosmeticId: cosmeticId),
    );
  }
}
