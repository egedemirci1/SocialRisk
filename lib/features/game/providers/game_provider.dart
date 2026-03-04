import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_game_source.dart';
import '../domain/game_entity.dart';
import '../domain/game_repository.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/models/enums.dart';

part 'game_provider.g.dart';

@Riverpod(keepAlive: true)
GameRepository gameRepository(Ref ref) {
  return FirebaseGameSource();
}

@riverpod
Stream<GameEntity?> watchGame(Ref ref, String gameId) {
  return ref.watch(gameRepositoryProvider).watchGame(gameId);
}

@Riverpod(keepAlive: true)
class GameController extends _$GameController {
  @override
  FutureOr<void> build() {}

  Future<void> acceptTask(String gameId) async {
    await ref.read(gameRepositoryProvider).acceptTask(gameId);
  }

  Future<void> setSpinningTarget({
    required String gameId,
    required String? target,
  }) async {
    await ref
        .read(gameRepositoryProvider)
        .setSpinningTarget(gameId: gameId, target: target);
  }

  Future<void> proceedToVoting(String gameId) async {
    await ref.read(gameRepositoryProvider).proceedToVoting(gameId);
  }

  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  }) async {
    await ref
        .read(gameRepositoryProvider)
        .assignTaskByCategory(gameId: gameId, category: category);
  }

  Future<void> chooseDifficulty({
    required String gameId,
    required String difficulty,
  }) async {
    await ref
        .read(gameRepositoryProvider)
        .chooseDifficulty(gameId: gameId, difficulty: difficulty);
  }

  Future<void> passTask({
    required String gameId,
    required String roomId,
    required String playerId,
  }) async {
    await ref
        .read(gameRepositoryProvider)
        .passTask(
          gameId: gameId,
          roomId: roomId,
          playerId: playerId,
          basePenalty: GameConstants.basePenalty,
        );
  }

  Future<void> applyScore({
    required String gameId,
    required String roomId,
    required String playerId,
    required int scoreToAdd,
    required int taskMultiplier,
    required int endConditionValue,
    required EndConditionType endConditionType,
    required int currentRound,
  }) async {
    final repo = ref.read(gameRepositoryProvider);

    // Puanı oyuncuya ekle
    await repo.updatePlayerScore(
      roomId: roomId,
      playerId: playerId,
      scoreToAdd: scoreToAdd,
    );

    // Bitiş koşulunu kontrol et
    bool shouldEnd = false;
    if (endConditionType == EndConditionType.rounds) {
      shouldEnd = currentRound >= endConditionValue;
    } else if (endConditionType == EndConditionType.score) {
      // Skor bazlı bitiş: repository üzerinden kontrol et
      shouldEnd = await repo.checkScoreEndCondition(
        roomId: roomId,
        targetScore: endConditionValue,
      );
    }

    // NOT: Ödül dağıtımı Cloud Function (onGameFinished) tarafından yapılır.
    // Client-side duplike dağıtım kaldırıldı.

    // Her durumda RoundResultScreen'e gitmek için sonuçları ayarla
    await repo.setRoundResult(
      gameId: gameId,
      score: scoreToAdd,
      multiplier: taskMultiplier,
    );

    if (shouldEnd) {
      await repo.endGame(gameId);
    }
  }

  Future<void> nextTurn(String gameId) async {
    await ref.read(gameRepositoryProvider).nextTurn(gameId);
  }

  // Faz 10: Ekonomi Modu
  Future<void> initEconomyRound({
    required String gameId,
    required String roomId,
  }) async {
    await ref
        .read(gameRepositoryProvider)
        .initEconomyRound(gameId: gameId, roomId: roomId);
  }

  Future<void> pickCategoryEconomy({
    required String gameId,
    required String playerId,
    required String category,
  }) async {
    await ref
        .read(gameRepositoryProvider)
        .pickCategoryEconomy(
          gameId: gameId,
          playerId: playerId,
          category: category,
        );
  }

  Future<void> endGame(String gameId) async {
    await ref.read(gameRepositoryProvider).endGame(gameId);
  }
}
