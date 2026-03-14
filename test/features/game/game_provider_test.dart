import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/features/game/domain/game_entity.dart';
import 'package:social_risk/features/game/providers/game_provider.dart';
import 'package:social_risk/shared/models/enums.dart';
import '../../helpers/fake_game_repository.dart';

void main() {
  group('GameController (FakeGameRepository)', () {
    test('gameRepositoryProvider override ile FakeGameRepository kullanılır', () async {
      final fake = FakeGameRepository();
      final container = ProviderContainer(
        overrides: [gameRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      expect(container.read(gameRepositoryProvider), same(fake));
    });

    group('Sıra yönetimi (nextTurn)', () {
      test('3 oyunculu senaryoda nextTurn ile currentPlayerId sırayla değişir, sonra 1. oyuncuya döner', () async {
        const gameId = 'g1';
        const roomId = 'r1';
        const turnOrder = ['p1', 'p2', 'p3'];
        final initial = GameEntity(
          gameId: gameId,
          roomId: roomId,
          currentPlayerId: 'p1',
          turnOrder: turnOrder,
          status: GameStatus.playing,
        );
        final fake = FakeGameRepository(initialGames: {gameId: initial});
        final container = ProviderContainer(
          overrides: [gameRepositoryProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        final controller = container.read(gameControllerProvider.notifier);
        await container.read(gameControllerProvider.future);

        expect(fake.getGame(gameId)!.currentPlayerId, 'p1');

        await controller.nextTurn(gameId);
        expect(fake.getGame(gameId)!.currentPlayerId, 'p2');

        await controller.nextTurn(gameId);
        expect(fake.getGame(gameId)!.currentPlayerId, 'p3');

        await controller.nextTurn(gameId);
        expect(fake.getGame(gameId)!.currentPlayerId, 'p1');

        await controller.nextTurn(gameId);
        expect(fake.getGame(gameId)!.currentPlayerId, 'p2');
      });
    });

    group('Puanlama ve sonuç (applyScore / usedTaskIds)', () {
      test('görev kabul edildiğinde puan doğru hesaplanır ve usedTaskIds\'e görev eklenir', () async {
        const gameId = 'g1';
        const roomId = 'r1';
        const taskId = 'task-42';
        const playerId = 'p1';
        final initial = GameEntity(
          gameId: gameId,
          roomId: roomId,
          currentPlayerId: playerId,
          turnOrder: [playerId],
          status: GameStatus.choosingDifficulty,
          usedTaskIds: [],
        );
        final fake = FakeGameRepository(initialGames: {gameId: initial});
        fake.setPendingTask(gameId, const TaskEntity(
          id: taskId,
          category: 'Fiziksel',
          content: 'Test',
          difficulty: 'medium',
          multiplier: 2,
        ));
        final container = ProviderContainer(
          overrides: [gameRepositoryProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        final controller = container.read(gameControllerProvider.notifier);
        await container.read(gameControllerProvider.future);

        await controller.chooseDifficulty(gameId: gameId, difficulty: 'medium');
        expect(fake.getGame(gameId)!.usedTaskIds, contains(taskId));

        await controller.acceptTask(gameId);
        expect(fake.getGame(gameId)!.status, GameStatus.performing);

        const scoreToAdd = 100;
        await controller.applyScore(
          gameId: gameId,
          roomId: roomId,
          playerId: playerId,
          scoreToAdd: scoreToAdd,
          audienceScore: 50,
          taskMultiplier: 2,
          endConditionValue: 500,
          endConditionType: EndConditionType.score,
          currentRound: 1,
        );
        expect(fake.getPlayerScore(roomId, playerId), scoreToAdd);
        expect(fake.getGame(gameId)!.lastRoundScore, scoreToAdd);
        expect(fake.getGame(gameId)!.lastRoundAudienceScore, 50);
        expect(fake.getGame(gameId)!.lastRoundMultiplier, 2);
        expect(fake.getGame(gameId)!.status, GameStatus.results);
      });

      test('görev geçildiğinde ceza uygulanır', () async {
        const gameId = 'g1';
        const roomId = 'r1';
        const playerId = 'p1';
        final initial = GameEntity(
          gameId: gameId,
          roomId: roomId,
          currentPlayerId: playerId,
          turnOrder: [playerId],
          status: GameStatus.playing,
        );
        final fake = FakeGameRepository(initialGames: {gameId: initial});
        final container = ProviderContainer(
          overrides: [gameRepositoryProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        final controller = container.read(gameControllerProvider.notifier);
        await container.read(gameControllerProvider.future);

        await controller.passTask(
          gameId: gameId,
          roomId: roomId,
          playerId: playerId,
        );
        expect(fake.getGame(gameId)!.status, GameStatus.results);
        expect(fake.getPlayerScore(roomId, playerId), lessThan(0));
      });
    });

    group('Ekonomi modu (pickCategoryEconomy)', () {
      test('seçilen kategori lockedCategories\'e girer, sıra sonraki seçiciye geçer', () async {
        const gameId = 'g1';
        const roomId = 'r1';
        const category = 'Bilgi';
        final pickOrder = ['p1', 'p2', 'p3'];
        final initial = GameEntity(
          gameId: gameId,
          roomId: roomId,
          currentPlayerId: pickOrder.first,
          turnOrder: pickOrder,
          status: GameStatus.playing,
          mode: GameMode.economy,
          categoryPickOrder: pickOrder,
          currentPickIndex: 0,
          lockedCategories: [],
          categoryMarketValues: {'Bilgi': 1, 'Fiziksel': 2},
        );
        final fake = FakeGameRepository(initialGames: {gameId: initial});
        final container = ProviderContainer(
          overrides: [gameRepositoryProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        final controller = container.read(gameControllerProvider.notifier);
        await container.read(gameControllerProvider.future);

        await controller.pickCategoryEconomy(
          gameId: gameId,
          playerId: 'p1',
          category: category,
        );
        final game = fake.getGame(gameId)!;
        expect(game.currentPickIndex, 1);
        expect(game.currentPlayerId, 'p2');
        expect(game.selectedCategory, category);
        expect(game.status, GameStatus.choosingDifficulty);
        expect(game.categoryMarketValues[category], lessThanOrEqualTo(1));
      });
    });

    group('Oyun sonu (endGame)', () {
      test('endGame çağrıldığında status finished olur ve stream kapatılır', () async {
        const gameId = 'g1';
        final initial = GameEntity(
          gameId: gameId,
          roomId: 'r1',
          currentPlayerId: 'p1',
          turnOrder: ['p1'],
          status: GameStatus.playing,
        );
        final fake = FakeGameRepository(initialGames: {gameId: initial});
        fake.watchGame(gameId); // controller oluştur
        final container = ProviderContainer(
          overrides: [gameRepositoryProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        final controller = container.read(gameControllerProvider.notifier);
        await container.read(gameControllerProvider.future);

        await controller.endGame(gameId);

        expect(fake.getGame(gameId)!.status, GameStatus.finished);
        expect(fake.isStreamClosed(gameId), isTrue);
      });
    });
  });
}
