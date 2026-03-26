import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/features/economy/domain/cosmetic_item_entity.dart';
import 'package:social_risk/features/economy/providers/economy_provider.dart';
import '../helpers/fake_economy_repository.dart';

void main() {
  group('EconomyController (with FakeEconomyRepository)', () {
    test('addPointsToWallet completes without error', () async {
      final container = ProviderContainer(
        overrides: [
          economyRepositoryProvider.overrideWithValue(FakeEconomyRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(economyControllerProvider.notifier);
      await controller.addPointsToWallet(uid: 'u1', points: 500);
      expect(container.read(economyControllerProvider).hasError, isFalse);
    });

    test('buyCosmetic completes without error when repo succeeds', () async {
      final container = ProviderContainer(
        overrides: [
          economyRepositoryProvider.overrideWithValue(FakeEconomyRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(economyControllerProvider.notifier);
      await controller.buyCosmetic(
        uid: 'u1',
        cosmeticId: 'frame_fire',
        price: 500,
      );
      expect(container.read(economyControllerProvider).hasError, isFalse);
    });

    test('buyCosmetic throws when repo throws', () async {
      final container = ProviderContainer(
        overrides: [
          economyRepositoryProvider.overrideWithValue(
            FakeEconomyRepository(buyThrows: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(economyControllerProvider.notifier);
      expect(
        controller.buyCosmetic(
          uid: 'u1',
          cosmeticId: 'x',
          price: 9999,
        ),
        throwsException,
      );
    });

    test('setActiveFrame completes without error', () async {
      final container = ProviderContainer(
        overrides: [
          economyRepositoryProvider.overrideWithValue(FakeEconomyRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(economyControllerProvider.notifier);
      await controller.setActiveFrame(uid: 'u1', cosmeticId: 'frame_fire');
      await controller.setActiveFrame(uid: 'u1', cosmeticId: null);
      expect(container.read(economyControllerProvider).hasError, isFalse);
    });

    test('setActiveTitle completes without error', () async {
      final container = ProviderContainer(
        overrides: [
          economyRepositoryProvider.overrideWithValue(FakeEconomyRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(economyControllerProvider.notifier);
      await controller.setActiveTitle(uid: 'u1', cosmeticId: 'title_king');
      await controller.setActiveTitle(uid: 'u1', cosmeticId: null);
      expect(container.read(economyControllerProvider).hasError, isFalse);
    });
  });

  group('fetchCosmeticsProvider (with FakeEconomyRepository)', () {
    test('returns list from fake repository', () async {
      final fakeList = [
        const CosmeticItemEntity(
          id: 'frame_fire',
          name: 'Ateş',
          nameEn: 'Fire',
          description: 'Çerçeve',
          descriptionEn: 'Frame',
          imageUrl: '🔥',
          price: 500,
          type: 'frame',
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          economyRepositoryProvider.overrideWithValue(
            FakeEconomyRepository(cosmetics: fakeList),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(fetchCosmeticsProvider.future);
      expect(result.length, 1);
      expect(result.first.id, 'frame_fire');
      expect(result.first.name, 'Ateş');
    });
  });
}
