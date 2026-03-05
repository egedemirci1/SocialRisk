import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/game_entity.dart';
import '../domain/game_repository.dart';
import 'game_model.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/constants/game_constants.dart';

class FirebaseGameSource implements GameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  CollectionReference<Map<String, dynamic>> get _gamesRef =>
      _firestore.collection('games');

  DocumentReference<Map<String, dynamic>> _gameDoc(String gameId) =>
      _gamesRef.doc(gameId);

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
      difficulty: task.difficulty,
      multiplier: task.multiplier,
    );
    await _gameDoc(gameId).update({
      'currentTask': taskModel.toJson(),
      'usedTaskIds': FieldValue.arrayUnion([task.id]),
      'spinningTarget': null,
    });
  }

  @override
  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  }) async {
    await _gameDoc(gameId).update({
      'selectedCategory': category,
      'status': 'choosingDifficulty',
      'spinningTarget': null,
    });
  }

  @override
  Future<void> chooseDifficulty({
    required String gameId,
    required String difficulty,
  }) async {
    try {
      final gameSnap = await _gameDoc(gameId).get();
      if (!gameSnap.exists) return;

      final game = GameModel.fromJson(gameSnap.data()!, gameSnap.id);
      final category = game.selectedCategory;

      if (category == null) {
        throw Exception('Önce kategori seçilmeli!');
      }

      // Pool'dan görev seç (Firestore sorgusu yapılmaz)
      final poolKey = '${category}_$difficulty';
      final pool = game.taskPool[poolKey] ?? [];

      // Kullanılmamış görevleri filtrele
      final available = pool
          .where((t) => !game.usedTaskIds.contains(t['id']))
          .toList();

      Map<String, dynamic>? selectedTask;

      if (available.isNotEmpty) {
        selectedTask = available[_random.nextInt(available.length)];
      } else if (pool.isNotEmpty) {
        // Tüm görevler kullanılmış — tekrar kullan (fallback)
        selectedTask = pool[_random.nextInt(pool.length)];
      }

      if (selectedTask == null) {
        throw Exception('Bu kategoride görev bulunamadı!');
      }

      // Görevin çarpanını seçilen zorluğa göre ayarla
      final multiplier = difficulty == 'easy'
          ? 1
          : (difficulty == 'medium' ? 2 : 3);

      final taskModel = TaskModel(
        id: selectedTask['id'] as String? ?? '',
        category: selectedTask['category'] as String? ?? category,
        content: selectedTask['content'] as String? ?? '',
        difficulty: selectedTask['difficulty'] as String? ?? difficulty,
        multiplier: multiplier,
      );

      await _gameDoc(gameId).update({
        'selectedDifficulty': difficulty,
        'currentTask': taskModel.toJson(),
        'usedTaskIds': FieldValue.arrayUnion([taskModel.id]),
        'status': 'playing',
      });
    } on FirebaseException catch (e) {
      throw Exception('Görev seçilirken bağlantı hatası oluştu: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> acceptTask(String gameId) async {
    await _gameDoc(gameId).update({'status': 'performing'});
  }

  @override
  Future<void> proceedToVoting(String gameId) async {
    await _gameDoc(gameId).update({'status': 'voting'});
  }

  @override
  Future<void> passTask({
    required String gameId,
    required String roomId,
    required String playerId,
    required int basePenalty,
  }) async {
    try {
      final playerDocRef = _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(playerId);
      final gameDocRef = _gameDoc(gameId);

      await _firestore.runTransaction((transaction) async {
        final playerSnap = await transaction.get(playerDocRef);
        final currentStreak = (playerSnap.data()?['passStreak'] as int?) ?? 0;
        final newStreak = currentStreak + 1;

        final penalty = AppHelpers.calculatePenalty(basePenalty, newStreak);

        transaction.update(playerDocRef, {
          'passStreak': newStreak,
          'score': FieldValue.increment(-penalty),
        });

        transaction.update(gameDocRef, {
          'status': 'results',
          'lastRoundScore': -penalty,
          'lastRoundMultiplier': 0,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Görevi geçerken bir hata oluştu: ${e.message}');
    } catch (e) {
      throw Exception('Görevi geçerken beklenmeyen bir hata oluştu: $e');
    }
  }

  @override
  Future<void> setRoundResult({
    required String gameId,
    required int score,
    required int multiplier,
  }) async {
    final snap = await _gameDoc(gameId).get();
    final currentPlayerId = snap.data()?['currentPlayerId'] as String?;

    await _gameDoc(gameId).update({
      'status': 'results',
      'lastRoundScore': score,
      'lastRoundMultiplier': multiplier,
      'lastRoundPlayerId': currentPlayerId,
    });
  }

  @override
  Future<void> nextTurn(String gameId) async {
    try {
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

      // Oyun bitiş kontrolü (Tur sayısına göre)
      if (isNewRound) {
        final roomSnap = await _firestore
            .collection('rooms')
            .doc(game.roomId)
            .get();
        if (roomSnap.exists) {
          final roomData = roomSnap.data()!;
          final endType = roomData['endConditionType'] as String?;
          final endVal = roomData['endConditionValue'] as int? ?? 10;

          if (endType == 'rounds' && game.currentRound >= endVal) {
            await _gameDoc(gameId).update({'status': 'finished'});
            return;
          }
        }
      }

      final updates = <String, dynamic>{
        'currentPlayerId': nextPlayerId,
        'currentTask': null,
        'selectedCategory': null,
        'selectedDifficulty': null,
        'status': 'playing',
        'spinningTarget': null,
      };

      if (isNewRound) {
        updates['currentRound'] = game.currentRound + 1;
      }

      await _gameDoc(gameId).update(updates);
    } on FirebaseException catch (e) {
      throw Exception('Sıra geçerken bağlantı hatası oluştu: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> nextRound(String gameId) async {
    final snap = await _gameDoc(gameId).get();
    if (!snap.exists) return;

    final game = GameModel.fromJson(snap.data()!, snap.id);

    await _gameDoc(gameId).update({
      'currentRound': game.currentRound + 1,
      'currentPlayerId': game.turnOrder.first,
      'currentTask': null,
      'selectedCategory': null,
      'selectedDifficulty': null,
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

  @override
  Future<bool> checkScoreEndCondition({
    required String roomId,
    required int targetScore,
  }) async {
    final playersSnap = await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .get();

    for (final doc in playersSnap.docs) {
      final score = doc.data()['score'] as int? ?? 0;
      if (score >= targetScore) {
        return true;
      }
    }
    return false;
  }

  // ── Faz 10: Ekonomi Modu ───────────────────────────────

  @override
  Future<void> initEconomyRound({
    required String gameId,
    required String roomId,
  }) async {
    final playersSnap = await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .get();

    final playerScores = <MapEntry<String, int>>[];
    for (final doc in playersSnap.docs) {
      final score = doc.data()['score'] as int? ?? 0;
      playerScores.add(MapEntry(doc.id, score));
    }
    playerScores.sort((a, b) => b.value.compareTo(a.value));

    final pickOrder = playerScores.map((e) => e.key).toList();

    await _gameDoc(gameId).update({
      'categoryPickOrder': pickOrder,
      'currentPickIndex': 0,
      'lockedCategories': [],
      'categoryMarketValues': GameConstants.defaultMarketValues,
      'currentTask': null,
      'selectedCategory': null,
      'selectedDifficulty': null,
      'spinningTarget': null,
      'currentPlayerId': pickOrder.first,
      'status': 'playing',
    });
  }

  @override
  Future<void> pickCategoryEconomy({
    required String gameId,
    required String playerId,
    required String category,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final gameDocRef = _gameDoc(gameId);
        final snap = await transaction.get(gameDocRef);

        if (!snap.exists) throw Exception('Oyun bulunamadı!');

        final game = GameModel.fromJson(snap.data()!, snap.id);

        if (game.lockedCategories.contains(category)) {
          throw Exception('Bu kategori kilitli!');
        }

        final updatedMarket = Map<String, int>.from(game.categoryMarketValues);
        final currentValue = updatedMarket[category] ?? 1;
        final newValue = (currentValue - GameConstants.marketDecayAmount).clamp(
          1,
          10,
        );
        updatedMarket[category] = newValue;

        final defaultVal = GameConstants.defaultMarketValues[category] ?? 1;
        final timesSelected = defaultVal - newValue + 1;
        final updatedLocked = List<String>.from(game.lockedCategories);
        if (timesSelected >= GameConstants.lockThreshold) {
          updatedLocked.add(category);
        }

        final nextPickIndex = game.currentPickIndex + 1;
        final allPicked = nextPickIndex >= game.categoryPickOrder.length;

        final updates = <String, dynamic>{
          'categoryMarketValues': updatedMarket,
          'lockedCategories': updatedLocked,
          'currentPickIndex': nextPickIndex,
          'selectedCategory': category,
          'status': 'choosingDifficulty',
          'spinningTarget': null,
        };

        if (allPicked) {
          updates['currentPlayerId'] = game.categoryPickOrder.first;
        } else {
          updates['currentPlayerId'] = game.categoryPickOrder[nextPickIndex];
        }

        transaction.update(gameDocRef, updates);
      });
    } on FirebaseException catch (e) {
      throw Exception(
        'Kategori seçilirken bağlantı hatası oluştu: ${e.message}',
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
