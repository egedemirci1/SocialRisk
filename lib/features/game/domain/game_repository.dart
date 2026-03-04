import '../domain/game_entity.dart';
import '../../../shared/models/enums.dart';

abstract class GameRepository {
  Future<String> startGame({
    required String roomId,
    required List<String> playerIds,
    required GameMode mode,
    List<String> categories = const [],
  });

  Stream<GameEntity?> watchGame(String gameId);

  Future<void> setSpinningTarget({
    required String gameId,
    required String? target,
  });

  Future<void> setCurrentTask({
    required String gameId,
    required TaskEntity task,
  });

  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  });

  /// Zorluk seçildiğinde Firestore'dan görevi çekip atar.
  Future<void> chooseDifficulty({
    required String gameId,
    required String roomId,
    required String difficulty,
  });

  Future<void> acceptTask(String gameId);

  Future<void> proceedToVoting(String gameId);

  Future<void> passTask({
    required String gameId,
    required String roomId,
    required String playerId,
    required int basePenalty,
  });

  Future<void> setRoundResult({
    required String gameId,
    required int score,
    required int multiplier,
  });

  Future<void> nextTurn(String gameId);

  Future<void> nextRound(String gameId);

  Future<void> updatePlayerScore({
    required String roomId,
    required String playerId,
    required int scoreToAdd,
  });

  Future<void> endGame(String gameId);

  // Faz 10: Ekonomi Modu
  Future<void> initEconomyRound({
    required String gameId,
    required String roomId,
  });

  Future<void> pickCategoryEconomy({
    required String gameId,
    required String playerId,
    required String category,
  });
}
