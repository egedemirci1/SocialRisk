import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/game_entity.dart';
import '../domain/game_repository.dart';
import 'game_model.dart';
import 'tasks_seed_data.dart';
import '../../core/utils/helpers.dart';

class FirebaseGameSource implements GameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  CollectionReference<Map<String, dynamic>> get _gamesRef =>
      _firestore.collection('games');

  DocumentReference<Map<String, dynamic>> _gameDoc(String gameId) =>
      _gamesRef.doc(gameId);

  @override
  Future<String> startGame({
    required String roomId,
    required List<String> playerIds,
  }) async {
    // Sırayı karıştır
    final shuffled = List<String>.from(playerIds)..shuffle(_random);
    final firstTask = _getRandomTask();

    final gameModel = GameModel(
      gameId: '',
      roomId: roomId,
      currentRound: 1,
      currentPlayerId: shuffled.first,
      currentTask: firstTask.toJson(),
      turnOrder: shuffled,
      status: 'playing',
    );

    final docRef = await _gamesRef.add(gameModel.toJson());
    return docRef.id;
  }

  @override
  Stream<GameEntity?> watchGame(String gameId) {
    return _gameDoc(gameId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return GameModel.fromJson(snap.data()!, snap.id).toEntity();
    });
  }

  @override
  Future<void> setCurrentTask({
    required String gameId,
    required TaskEntity task,
  }) async {
    final taskModel = TaskModel(
      id: task.id,
      category: task.category,
      content: task.content,
      multiplier: task.multiplier,
    );
    await _gameDoc(gameId).update({'currentTask': taskModel.toJson()});
  }

  @override
  Future<void> acceptTask(String gameId) async {
    // Görev kabul edildi — oylama başlayacak
    // Bu bilgiyi UI tarafı handle edecek
  }

  @override
  Future<void> passTask({
    required String gameId,
    required String roomId,
    required String playerId,
    required int basePenalty,
  }) async {
    // Pas streak artır
    final playerDoc = _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .doc(playerId);

    final playerSnap = await playerDoc.get();
    final currentStreak = (playerSnap.data()?['passStreak'] as int?) ?? 0;
    final newStreak = currentStreak + 1;
    final penalty = AppHelpers.calculatePenalty(basePenalty, newStreak);

    await playerDoc.update({
      'passStreak': newStreak,
      'score': FieldValue.increment(-penalty),
    });

    // Yeni görev ata
    final newTask = _getRandomTask();
    await setCurrentTask(gameId: gameId, task: newTask.toEntity());
  }

  @override
  Future<void> nextTurn(String gameId) async {
    final snap = await _gameDoc(gameId).get();
    if (!snap.exists) return;

    final game = GameModel.fromJson(snap.data()!, snap.id);
    final currentIndex = game.turnOrder.indexOf(game.currentPlayerId);
    final nextIndex = (currentIndex + 1) % game.turnOrder.length;
    final isNewRound = nextIndex == 0;

    final newTask = _getRandomTask();

    final updates = <String, dynamic>{
      'currentPlayerId': game.turnOrder[nextIndex],
      'currentTask': newTask.toJson(),
    };

    if (isNewRound) {
      updates['currentRound'] = game.currentRound + 1;
    }

    await _gameDoc(gameId).update(updates);
  }

  @override
  Future<void> nextRound(String gameId) async {
    final snap = await _gameDoc(gameId).get();
    if (!snap.exists) return;

    final game = GameModel.fromJson(snap.data()!, snap.id);
    final newTask = _getRandomTask();

    await _gameDoc(gameId).update({
      'currentRound': game.currentRound + 1,
      'currentPlayerId': game.turnOrder.first,
      'currentTask': newTask.toJson(),
    });
  }

  @override
  Future<void> updatePlayerScore({
    required String roomId,
    required String playerId,
    required int scoreToAdd,
  }) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .doc(playerId)
        .update({'score': FieldValue.increment(scoreToAdd)});
  }

  @override
  Future<void> endGame(String gameId) async {
    await _gameDoc(gameId).update({'status': 'finished'});
  }

  TaskModel _getRandomTask() {
    return tasksSeedData[_random.nextInt(tasksSeedData.length)];
  }
}
