import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/game_entity.dart';
import '../domain/game_repository.dart';
import 'game_model.dart';
import 'tasks_seed_data.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/models/enums.dart';

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
    required GameDifficulty difficulty,
  }) async {
    // Sırayı karıştır
    final shuffled = List<String>.from(playerIds)..shuffle(_random);

    final gameModel = GameModel(
      gameId: '',
      roomId: roomId,
      currentRound: 1,
      currentPlayerId: shuffled.first,
      currentTask: null, // Çark çevrilecek, görev atanmayacak
      turnOrder: shuffled,
      status: 'playing',
      difficulty: difficulty.name,
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
  Future<void> setSpinningTarget({
    required String gameId,
    required String? target,
  }) async {
    await _gameDoc(gameId).update({'spinningTarget': target});
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
    await _gameDoc(gameId).update({
      'currentTask': taskModel.toJson(),
      'usedTaskIds': FieldValue.arrayUnion([task.id]), // E15: Görevi kullanıldı olarak işaretle
      'spinningTarget': null,
    });
  }

  @override
  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  }) async {
    final snap = await _gameDoc(gameId).get();
    if (!snap.exists) return;

    final game = GameModel.fromJson(snap.data()!, snap.id);
    final usedIds = game.usedTaskIds;
    final difficulty = GameDifficulty.values.firstWhere(
        (e) => e.name == game.difficulty,
        orElse: () => GameDifficulty.mixed);

    // Kategoriye uyan ve daha önce kullanılmamış görevleri bul
    var availableTasks = tasksSeedData.where((t) => 
      t.category == category && !usedIds.contains(t.id)
    ).toList();

    // Zorluğa göre filtreleme
    if (difficulty != GameDifficulty.mixed) {
      final targetMultiplier = difficulty == GameDifficulty.easy 
        ? 1 
        : (difficulty == GameDifficulty.medium ? 2 : 3);
        
      final filteredByDifficulty = availableTasks.where((t) => t.multiplier == targetMultiplier).toList();
      
      // Eğer seçili zorlukta görev kalmadıysa filtreyi esnet
      if (filteredByDifficulty.isNotEmpty) {
        availableTasks = filteredByDifficulty;
      }
    }

    // Eğer o kategorideki tüm (veya ilgili zorluktaki) görevler bittiyse, 
    // fallback olarak kullanılmışları da dahil et (sadece o kategori için)
    if (availableTasks.isEmpty) {
      availableTasks = tasksSeedData.where((t) => t.category == category).toList();
    }

    // Rastgele birini seç
    final selectedTask = availableTasks[_random.nextInt(availableTasks.length)];

    await setCurrentTask(
      gameId: gameId, 
      task: selectedTask.toEntity(),
    );
  }

  @override
  Future<void> acceptTask(String gameId) async {
    // Görev kabul edildi — oyun durumu 'performing' (görevi yapma) aşamasına geçer.
    await _gameDoc(gameId).update({'status': 'performing'});
  }

  @override
  Future<void> proceedToVoting(String gameId) async {
    // Görev yapıldı — oylama aşamasına geç.
    await _gameDoc(gameId).update({'status': 'voting'});
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
    
    // E11: README'ye göre basePenalty 50 olmalı, AppHelpers 100 kullanıyordu. 
    // Parametre olarak gelen basePenalty'yi (GameConstants'tan gelir) kullan.
    final penalty = AppHelpers.calculatePenalty(basePenalty, newStreak);

    await playerDoc.update({
      'passStreak': newStreak,
      'score': FieldValue.increment(-penalty),
    });

    // Pas deyince sıranın bitmesi yeni kural, o yüzden burada yeni görev atamıyoruz.
    // Oyun statüsünü koruyarak nextTurn'e geçmiyoruz. RoundResultScreen'e yönlendiriyoruz.
    await _gameDoc(gameId).update({
      'status': 'results',
      'lastRoundScore': -penalty,
      'lastRoundMultiplier': 0, // Pas geçildiğini belirtmek için
    });
  }

  @override
  Future<void> setRoundResult({
    required String gameId,
    required int score,
    required int multiplier,
  }) async {
    await _gameDoc(gameId).update({
      'status': 'results',
      'lastRoundScore': score,
      'lastRoundMultiplier': multiplier,
    });
  }

  @override
  Future<void> nextTurn(String gameId) async {
    final snap = await _gameDoc(gameId).get();
    if (!snap.exists) return;

    final game = GameModel.fromJson(snap.data()!, snap.id);
    
    // Aktif oyuncuları kontrol et
    final playersSnap = await _firestore
        .collection('rooms')
        .doc(game.roomId)
        .collection('players')
        .get();
    final activePlayerIds = playersSnap.docs.map((d) => d.id).toSet();
    
    // Sıradaki aktif oyuncuyu bul (çıkmış oyuncuları atla)
    final currentIndex = game.turnOrder.indexOf(game.currentPlayerId);
    String? nextPlayerId;
    int nextIndex = currentIndex;
    bool isNewRound = false;
    
    for (int i = 1; i <= game.turnOrder.length; i++) {
      nextIndex = (currentIndex + i) % game.turnOrder.length;
      if (nextIndex == 0) isNewRound = true;
      
      if (activePlayerIds.contains(game.turnOrder[nextIndex])) {
        nextPlayerId = game.turnOrder[nextIndex];
        break;
      }
    }
    
    // Kimse kalmadıysa oyunu bitir
    if (nextPlayerId == null) {
      await _gameDoc(gameId).update({'status': 'finished'});
      return;
    }

    final updates = <String, dynamic>{
      'currentPlayerId': nextPlayerId,
      'currentTask': null,
      'status': 'playing',
      'spinningTarget': null,
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

    await _gameDoc(gameId).update({
      'currentRound': game.currentRound + 1,
      'currentPlayerId': game.turnOrder.first,
      'currentTask': null, // Çark çevrilecek
      'spinningTarget': null,
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
