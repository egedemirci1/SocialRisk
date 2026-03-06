import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/game/domain/game_entity.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('GameEntity - Unit Tests', () {
    test('GameEntity varsayılan değerlerle doğru oluşturulmalı (Single Behavior)', () {
      // Arrange & Act
      final game = GameEntity(
        gameId: 'test_game',
        roomId: 'test_room',
        currentPlayerId: 'player_1',
        turnOrder: ['player_1', 'player_2'],
      );

      // Assert
      expect(game.gameId, 'test_game');
      expect(game.roomId, 'test_room');
      expect(game.currentRound, 1); // Default value
      expect(game.status, GameStatus.playing); // Default value
      expect(game.difficulty, GameDifficulty.mixed); // Default value
      expect(game.mode, GameMode.classic); // Default value
    });

    test('GameEntity özel değerlerle doğru oluşturulmalı', () {
      // Arrange & Act
      final game = GameEntity(
        gameId: 'test_game_2',
        roomId: 'test_room_2',
        currentRound: 5,
        currentPlayerId: 'player_2',
        turnOrder: ['player_1', 'player_2'],
        status: GameStatus.voting,
        difficulty: GameDifficulty.hard,
        mode: GameMode.economy,
      );

      // Assert
      expect(game.currentRound, 5);
      expect(game.status, GameStatus.voting);
      expect(game.difficulty, GameDifficulty.hard);
      expect(game.mode, GameMode.economy);
    });
  });
}
