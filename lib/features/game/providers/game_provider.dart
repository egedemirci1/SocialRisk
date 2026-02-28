import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_game_source.dart';
import '../domain/game_entity.dart';
import '../domain/game_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/models/enums.dart';
import '../../economy/providers/economy_provider.dart';

part 'game_provider.g.dart';

@Riverpod(keepAlive: true)
GameRepository gameRepository(Ref ref) {
  return FirebaseGameSource();
}

@Riverpod(keepAlive: true)
Stream<GameEntity?> watchGame(Ref ref, String gameId) {
  return ref.watch(gameRepositoryProvider).watchGame(gameId);
}

@Riverpod(keepAlive: true)
class GameController extends _$GameController {
  @override
  FutureOr<String?> build() => null;

  Future<String> startGame({
    required String roomId,
    required List<String> playerIds,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() =>
      ref.read(gameRepositoryProvider).startGame(
        roomId: roomId,
        playerIds: playerIds,
      ),
    );
    state = result;
    return result.value ?? '';
  }

  Future<void> acceptTask(String gameId) async {
    await ref.read(gameRepositoryProvider).acceptTask(gameId);
  }

  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  }) async {
    await ref.read(gameRepositoryProvider).assignTaskByCategory(
      gameId: gameId,
      category: category,
    );
  }

  Future<void> passTask({
    required String gameId,
    required String roomId,
    required String playerId,
  }) async {
    await ref.read(gameRepositoryProvider).passTask(
      gameId: gameId,
      roomId: roomId,
      playerId: playerId,
      basePenalty: GameConstants.basePenalty,
    );
  }

  Future<void> applyScoreAndNextTurn({
    required String gameId,
    required String roomId,
    required String playerId,
    required int scoreToAdd,
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
      // Tur bazlı bitiş
      shouldEnd = currentRound >= endConditionValue;
    } else if (endConditionType == EndConditionType.score) {
      // Skor bazlı bitiş: E12. Fetch the player list to check their scores
      final playersSnap = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .get();
      
      for (final doc in playersSnap.docs) {
        final score = doc.data()['score'] as int? ?? 0;
        // Check condition: Any player's score >= required score
        if (score >= endConditionValue) {
          shouldEnd = true;
          break;
        }
      }
    }

    if (shouldEnd) {
      await repo.endGame(gameId);
      
      // Oyun sonu - E23: İlgili tüm oyuncuların kazançlarını hesaplarına yatır.
      final updatedPlayersSnap = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .get();
      
      for (final doc in updatedPlayersSnap.docs) {
        final score = doc.data()['score'] as int? ?? 0;
        if (score > 0) {
          await ref.read(economyControllerProvider.notifier)
            .addPointsToWallet(uid: doc.id, points: score);
        }
      }
    } else {
      await repo.nextTurn(gameId);
    }
  }

  Future<void> endGame(String gameId) async {
    await ref.read(gameRepositoryProvider).endGame(gameId);
  }
}
