import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/game_entity.dart';
import '../domain/game_repository.dart';
import 'game_model.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/constants/game_constants.dart';

class FirebaseGameSource implements GameRepository {
  final FirebaseFirestore _firestore;
  final Random _random;

  FirebaseGameSource({
    FirebaseFirestore? firestore,
    Random? random,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _random = random ?? Random();

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
        final gameSnap = await transaction.get(gameDocRef);
        if (!gameSnap.exists || gameSnap.data() == null) {
          throw Exception('Oyun bulunamadı');
        }
        final game = GameModel.fromJson(gameSnap.data()!, gameSnap.id);

        final currentStreak = (playerSnap.data()?['passStreak'] as int?) ?? 0;
        final newStreak = currentStreak + 1;

        final penalty = AppHelpers.calculatePenalty(basePenalty, newStreak);

        transaction.update(playerDocRef, {
          'passStreak': newStreak,
          'score': FieldValue.increment(-penalty),
        });

        final updates = <String, dynamic>{
          'status': 'results',
          'lastRoundScore': -penalty,
          'lastRoundMultiplier': 0,
          'lastRoundPlayerId': playerId,
        };

        // Ekonomi Modu: Pas sonrası sıra bir sonraki oyuncuya geçmeli (sıra atlamama bug fix)
        if (game.categoryPickOrder.isNotEmpty) {
          final nextPickIndex = game.currentPickIndex + 1;
          if (nextPickIndex >= game.categoryPickOrder.length) {
            updates['currentPickIndex'] = 0;
            updates['currentRound'] = game.currentRound + 1;
            updates['currentPlayerId'] = game.categoryPickOrder[0];
          } else {
            updates['currentPickIndex'] = nextPickIndex;
            updates['currentPlayerId'] =
                game.categoryPickOrder[nextPickIndex];
          }
        }

        transaction.update(gameDocRef, updates);
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
    required String roomId,
    required String playerId,
    required int score,
    required int audienceScore,
    required int multiplier,
  }) async {
    try {
      final gameDocRef = _gameDoc(gameId);
      final playerDocRef = _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(playerId);

      await _firestore.runTransaction((transaction) async {
        final gameSnap = await transaction.get(gameDocRef);
        if (!gameSnap.exists) return;
        final game = GameModel.fromJson(gameSnap.data()!, gameSnap.id);

        transaction.update(playerDocRef, {
          'score': FieldValue.increment(score),
        });

        final updates = <String, dynamic>{
          'status': 'results',
          'lastRoundScore': score,
          'lastRoundAudienceScore': audienceScore,
          'lastRoundMultiplier': multiplier,
          'lastRoundPlayerId': playerId,
        };

        // Ekonomi Modu: Seçilmiş kategorinin değerini düşür (tur tamamlandığında)
        if (game.categoryPickOrder.isNotEmpty && game.selectedCategory != null) {
          final marketValues = Map<String, int>.from(game.categoryMarketValues);
          final selectedCategory = game.selectedCategory!;
          final currentValue = marketValues[selectedCategory] ?? 10;
          final newValue = (currentValue - GameConstants.marketDecayAmount)
              .clamp(GameConstants.minMarketValue, GameConstants.maxMarketValue);
          marketValues[selectedCategory] = newValue;
          updates['categoryMarketValues'] = marketValues;
        }

        // Ekonomi Modu: Sıra Değişimi Hazırlığı
        if (game.categoryPickOrder.isNotEmpty) {
          final nextPickIndex = game.currentPickIndex + 1;
          if (nextPickIndex >= game.categoryPickOrder.length) {
            updates['currentPickIndex'] = 0;
            updates['currentRound'] = game.currentRound + 1;
            updates['currentPlayerId'] = game.categoryPickOrder[0];
            // Yeni tur başlarken sıfır değerli kategorileri 10'a çek ve hotCategory seç
            final marketValues = Map<String, int>.from(
              updates['categoryMarketValues'] as Map<String, int>? ?? game.categoryMarketValues,
            );
            for (final k in marketValues.keys.toList()) {
              if ((marketValues[k] ?? 0) == 0) marketValues[k] = 10;
            }
            final atTen = marketValues.keys.where((c) => (marketValues[c] ?? 0) == 10).toList();
            updates['categoryMarketValues'] = marketValues;
            updates['hotCategory'] = atTen.isNotEmpty ? atTen[_random.nextInt(atTen.length)] : null;
          } else {
            updates['currentPickIndex'] = nextPickIndex;
            updates['currentPlayerId'] = game.categoryPickOrder[nextPickIndex];
          }
        }

        transaction.update(gameDocRef, updates);
      });
    } on FirebaseException catch (e) {
      throw Exception('Sonuçlar kaydedilirken hata oluştu: ${e.message}');
    } catch (e) {
      throw Exception('Sonuçlar kaydedilirken beklenmeyen hata: $e');
    }
  }

  @override
  Future<void> nextTurn(String gameId) async {
    try {
      final gameDocRef = _gameDoc(gameId);

      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(gameDocRef);
        if (!snap.exists) return;

        final game = GameModel.fromJson(snap.data()!, snap.id);

        // Economy Modu Kontrolü
        if (game.categoryPickOrder.isNotEmpty) {
          final updates = <String, dynamic>{
            // currentPlayerId zaten setRoundResult ile güncellendiği için 
            // burada sadece status ve temizlik yapıyoruz
            'currentTask': null,
            'selectedCategory': null,
            'selectedDifficulty': null,
            'status': 'playing',
            'spinningTarget': null,
          };
          transaction.update(gameDocRef, updates);
          return;
        }

        // Çark modu: Borsa ile aynı mantık — sırayla +1, döngüsel
        if (game.turnOrder.isEmpty) return;
        final currentIndex = game.turnOrder.indexOf(game.currentPlayerId);
        final idx = currentIndex >= 0 ? currentIndex : 0;
        final nextIndex = (idx + 1) % game.turnOrder.length;
        final nextPlayerId = game.turnOrder[nextIndex];
        final isNewRound = nextIndex == 0;

        if (isNewRound) {
          final roomDocRef = _firestore.collection('rooms').doc(game.roomId);
          final roomSnap = await transaction.get(roomDocRef);
          if (roomSnap.exists) {
            final roomData = roomSnap.data()!;
            final endType = roomData['endConditionType'] as String?;
            final endVal = roomData['endConditionValue'] as int? ?? 10;
            if (endType == 'rounds' && game.currentRound >= endVal) {
              transaction.update(gameDocRef, {'status': 'results'});
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
        transaction.update(gameDocRef, updates);
      });
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
    final gameSnap = await _gameDoc(gameId).get();
    if (!gameSnap.exists) return;
    final game = GameModel.fromJson(gameSnap.data()!, gameSnap.id);
    if (game.status == 'finished') return;
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

    final gameSnap = await _gameDoc(gameId).get();
    if (!gameSnap.exists) return;
    final game = GameModel.fromJson(gameSnap.data()!, gameSnap.id);

    final marketValues = Map<String, int>.from(game.categoryMarketValues);
    final pickCounts = { for (final c in marketValues.keys) c: 0 };
    
    final atTen = marketValues.keys.where((c) => (marketValues[c] ?? 0) == 10).toList();
    final hotCategory = atTen.isNotEmpty ? atTen[_random.nextInt(atTen.length)] : null;

    await _gameDoc(gameId).update({
      'categoryPickOrder': pickOrder,
      'currentPickIndex': 0,
      'lockedCategories': [],
      'categoryMarketValues': marketValues,
      'categoryPickCounts': pickCounts,
      'currentTask': null,
      'selectedCategory': null,
      'selectedDifficulty': null,
      'spinningTarget': null,
      'currentPlayerId': pickOrder.first,
      'status': 'playing',
      if (hotCategory != null) 'hotCategory': hotCategory,
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

        // Seçim sayısını güncelle ve kilitleme kontrolü yap
        final updatedPickCounts = Map<String, int>.from(game.categoryPickCounts);
        final newPickCount = (updatedPickCounts[category] ?? 0) + 1;
        updatedPickCounts[category] = newPickCount;

        final updatedLocked = List<String>.from(game.lockedCategories);
        final totalCategories = game.categoryMarketValues.keys.length;
        final wouldLockAll = (updatedLocked.length + 1) >= totalCategories;
        if (newPickCount >= GameConstants.lockThreshold && !wouldLockAll) {
          if (!updatedLocked.contains(category)) {
            updatedLocked.add(category);
          }
        }

        final updates = <String, dynamic>{
          'categoryPickCounts': updatedPickCounts,
          'lockedCategories': updatedLocked,
          'selectedCategory': category,
          'status': 'choosingDifficulty',
          'spinningTarget': null,
        };

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

  @override
  Future<void> removePlayerFromGame({
    required String gameId,
    required String playerId,
  }) async {
    try {
      final snap = await _gameDoc(gameId).get();
      if (!snap.exists) return;

      final game = GameModel.fromJson(snap.data()!, snap.id);
      if (game.status != 'playing') return;

      final newTurnOrder =
          game.turnOrder.where((id) => id != playerId).toList();
      final newCategoryPickOrder = game.categoryPickOrder.isEmpty
          ? <String>[]
          : game.categoryPickOrder.where((id) => id != playerId).toList();

      if (newTurnOrder.isEmpty) {
        await _gameDoc(gameId).update({'status': 'finished'});
        return;
      }

      String newCurrentPlayerId = game.currentPlayerId;
      int newCurrentPickIndex = game.currentPickIndex;

      if (game.currentPlayerId == playerId) {
        if (game.categoryPickOrder.isNotEmpty) {
          final list = game.categoryPickOrder;
          final len = list.length;
          for (var i = 1; i <= len; i++) {
            final idx = (game.currentPickIndex + i) % len;
            if (list[idx] != playerId) {
              newCurrentPlayerId = list[idx];
              newCurrentPickIndex =
                  newCategoryPickOrder.indexOf(newCurrentPlayerId);
              if (newCurrentPickIndex < 0) newCurrentPickIndex = 0;
              break;
            }
          }
        } else {
          final list = game.turnOrder;
          final currentIdx = list.indexOf(playerId);
          final len = list.length;
          for (var i = 1; i <= len; i++) {
            final idx = (currentIdx + i) % len;
            if (list[idx] != playerId) {
              newCurrentPlayerId = list[idx];
              break;
            }
          }
          newCurrentPickIndex = 0;
        }
      } else if (newCategoryPickOrder.isNotEmpty) {
        final idx = newCategoryPickOrder.indexOf(game.currentPlayerId);
        newCurrentPickIndex = idx >= 0 ? idx : 0;
      }

      final updates = <String, dynamic>{
        'turnOrder': newTurnOrder,
        'categoryPickOrder': newCategoryPickOrder,
        'currentPlayerId': newCurrentPlayerId,
        'currentPickIndex': newCurrentPickIndex,
      };
      await _gameDoc(gameId).update(updates);
    } on FirebaseException catch (e) {
      throw Exception(
        'Oyuncu oyundan çıkarılırken hata oluştu: ${e.message}',
      );
    }
  }

}
