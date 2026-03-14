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
        currentPlayerId: 'p1',
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
  });
}
