import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/game/domain/game_end_utils.dart';
import 'package:social_risk/features/game/domain/game_entity.dart';
import 'package:social_risk/features/room/domain/room_entity.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('GameEndUtils.shouldEndAfterRound', () {
    test('rounds modunda son aktif oyuncuda ve hedef tura ulaşıldığında true döner', () {
      const game = GameEntity(
        gameId: 'g1',
        roomId: 'r1',
        currentRound: 3,
        currentPlayerId: 'p3',
        lastRoundPlayerId: 'p3',
        turnOrder: ['p1', 'p2', 'p3'],
      );
      final room = RoomEntity(
        roomCode: 'R1',
        hostId: 'h1',
        createdAt: DateTime(2024),
        endConditionType: EndConditionType.rounds,
        endConditionValue: 3,
      );
      const players = [
        PlayerEntity(id: 'p1', displayName: 'A'),
        PlayerEntity(id: 'p2', displayName: 'B'),
        PlayerEntity(id: 'p3', displayName: 'C'),
      ];

      final result = GameEndUtils.shouldEndAfterRound(
        game: game,
        room: room,
        players: players,
      );
      expect(result, isTrue);
    });

    test('ekonomi modunda categoryPickOrder kullanarak son oyuncuda true döner', () {
      const game = GameEntity(
        gameId: 'g1',
        roomId: 'r1',
        currentRound: 2,
        currentPlayerId: 'p2',
        lastRoundPlayerId: 'p2',
        turnOrder: ['p1', 'p2', 'p3'],
        categoryPickOrder: ['p2', 'p3', 'p1', 'p2'],
        mode: GameMode.economy,
      );
      final room = RoomEntity(
        roomCode: 'R1',
        hostId: 'h1',
        createdAt: DateTime(2024),
        endConditionType: EndConditionType.rounds,
        endConditionValue: 2,
      );
      const players = [
        PlayerEntity(id: 'p1', displayName: 'A'),
        PlayerEntity(id: 'p2', displayName: 'B'),
      ];

      final result = GameEndUtils.shouldEndAfterRound(
        game: game,
        room: room,
        players: players,
      );
      expect(result, isTrue);
    });

    test('ekonomi modunda categoryPickOrder ile son oyuncu değilse false döner', () {
      const game = GameEntity(
        gameId: 'g1',
        roomId: 'r1',
        currentRound: 2,
        currentPlayerId: 'p1',
        lastRoundPlayerId: 'p1',
        turnOrder: ['p1', 'p2', 'p3'],
        categoryPickOrder: ['p1', 'p2'],
        mode: GameMode.economy,
      );
      final room = RoomEntity(
        roomCode: 'R1',
        hostId: 'h1',
        createdAt: DateTime(2024),
        endConditionType: EndConditionType.rounds,
        endConditionValue: 2,
      );
      const players = [
        PlayerEntity(id: 'p1', displayName: 'A'),
        PlayerEntity(id: 'p2', displayName: 'B'),
      ];

      final result = GameEndUtils.shouldEndAfterRound(
        game: game,
        room: room,
        players: players,
      );
      expect(result, isFalse);
    });

    test('score modunda biri hedef puana ulaştığında true döner', () {
      const game = GameEntity(
        gameId: 'g1',
        roomId: 'r1',
        currentPlayerId: 'p2',
        lastRoundPlayerId: 'p2',
        turnOrder: ['p1', 'p2'],
      );
      final room = RoomEntity(
        roomCode: 'R1',
        hostId: 'h1',
        createdAt: DateTime(2024),
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
      );
      const players = [
        PlayerEntity(id: 'p1', displayName: 'A', score: 520),
        PlayerEntity(id: 'p2', displayName: 'B', score: 490),
      ];

      final result = GameEndUtils.shouldEndAfterRound(
        game: game,
        room: room,
        players: players,
      );
      expect(result, isTrue);
    });

    test('score modunda hedefe ulaÅŸÄ±lsa bile tur bitmeden false dÃ¶ner', () {
      const game = GameEntity(
        gameId: 'g1',
        roomId: 'r1',
        currentPlayerId: 'p1',
        lastRoundPlayerId: 'p1',
        turnOrder: ['p1', 'p2'],
      );
      final room = RoomEntity(
        roomCode: 'R1',
        hostId: 'h1',
        createdAt: DateTime(2024),
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
      );
      const players = [
        PlayerEntity(id: 'p1', displayName: 'A', score: 520),
        PlayerEntity(id: 'p2', displayName: 'B', score: 490),
      ];

      final result = GameEndUtils.shouldEndAfterRound(
        game: game,
        room: room,
        players: players,
      );
      expect(result, isFalse);
    });

    test('score modunda challenge ham puani degil gerçek toplam skor dikkate alınır', () {
      const game = GameEntity(
        gameId: 'g1',
        roomId: 'r1',
        currentPlayerId: 'p1',
        lastRoundPlayerId: 'p1',
        lastRoundScore: 15,
        lastRoundMultiplier: 3,
        turnOrder: ['p1', 'p2'],
      );
      final room = RoomEntity(
        roomCode: 'R1',
        hostId: 'h1',
        createdAt: DateTime(2024),
        endConditionType: EndConditionType.score,
        endConditionValue: 100,
      );
      const players = [
        // Oyuncu 70 puandayken 30'luk challenge secip nötr oyla 15 alip 85'e cikiyor.
        PlayerEntity(id: 'p1', displayName: 'A', score: 85),
        PlayerEntity(id: 'p2', displayName: 'B', score: 40),
      ];

      final result = GameEndUtils.shouldEndAfterRound(
        game: game,
        room: room,
        players: players,
      );
      expect(result, isFalse);
    });

    test('final sÄ±ralamada eÅŸit puanda toplam like sayÄ±sÄ± tie-break olur', () {
      const players = [
        PlayerEntity(id: 'p1', displayName: 'A', score: 100, totalLikes: 7),
        PlayerEntity(id: 'p2', displayName: 'B', score: 100, totalLikes: 11),
        PlayerEntity(id: 'p3', displayName: 'C', score: 90, totalLikes: 20),
      ];

      final sorted = [...players]..sort(GameEndUtils.comparePlayersForFinalRanking);

      expect(sorted.map((player) => player.id), ['p2', 'p1', 'p3']);
    });
  });
}
