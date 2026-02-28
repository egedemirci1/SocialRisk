import '../domain/game_entity.dart';

abstract class GameRepository {
  Future<String> startGame({
    required String roomId,
    required List<String> playerIds,
  });

  Stream<GameEntity?> watchGame(String gameId);

  Future<void> setCurrentTask({
    required String gameId,
    required TaskEntity task,
  });

  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  });

  Future<void> acceptTask(String gameId);

  Future<void> passTask({
    required String gameId,
    required String roomId,
    required String playerId,
    required int basePenalty,
  });

  Future<void> nextTurn(String gameId);

  Future<void> nextRound(String gameId);

  Future<void> updatePlayerScore({
    required String roomId,
    required String playerId,
    required int scoreToAdd,
  });

  Future<void> endGame(String gameId);
}
