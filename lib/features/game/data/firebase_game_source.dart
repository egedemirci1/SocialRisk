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
    required String roomId,
    required String playerId,
    required int score,
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
          'lastRoundMultiplier': multiplier,
          'lastRoundPlayerId': playerId,
        };

        // Ekonomi Modu: Sıra Değişimi Hazırlığı
        if (game.categoryPickOrder.isNotEmpty) {
          final nextPickIndex = game.currentPickIndex + 1;
          if (nextPickIndex >= game.categoryPickOrder.length) {
            updates['currentPickIndex'] = 0;
            updates['currentRound'] = game.currentRound + 1;
            // Tur başa döndüğünde ilk oyuncuyu ata
            updates['currentPlayerId'] = game.categoryPickOrder[0];
          } else {
            updates['currentPickIndex'] = nextPickIndex;
            // SIRADAKİ OYUNCUYU BURADA GÜNCELLE:
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

        // Klasik Mod Mantığı (Mevcut)
        // Aktif oyuncuları transaction içinden tek tek kontrol et
        final activePlayerIds = <String>{};
        for (final pid in game.turnOrder) {
          final pSnap = await transaction.get(
            _firestore
                .collection('rooms')
                .doc(game.roomId)
                .collection('players')
                .doc(pid),
          );
          if (pSnap.exists) {
            activePlayerIds.add(pid);
          }
        }

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
          transaction.update(gameDocRef, {'status': 'finished'});
          return;
        }

        // Oyun bitiş kontrolü (Tur sayısına göre)
        if (isNewRound) {
          final roomDocRef = _firestore.collection('rooms').doc(game.roomId);
          final roomSnap = await transaction.get(roomDocRef);
          
          if (roomSnap.exists) {
            final roomData = roomSnap.data()!;
            final endType = roomData['endConditionType'] as String?;
            final endVal = roomData['endConditionValue'] as int? ?? 10;

            if (endType == 'rounds' && game.currentRound >= endVal) {
              transaction.update(gameDocRef, {'status': 'finished'});
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
      'categoryPickCounts': GameConstants.defaultPickCounts,
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

        final marketValues = Map<String, int>.from(game.categoryMarketValues);
        final oldValue = marketValues[category] ?? 10;
        final newValue = (oldValue - GameConstants.marketDecayAmount)
            .clamp(GameConstants.minMarketValue, GameConstants.maxMarketValue);
        final drop = oldValue - newValue;

        // Kendi değerini düşür
        marketValues[category] = newValue;

        // Puan düştüyse başka birine aktar
        if (drop > 0) {
          final otherCategories = marketValues.keys
              .where((c) => c != category && !game.lockedCategories.contains(c))
              .toList();

          if (otherCategories.isNotEmpty) {
            final rival = otherCategories[_random.nextInt(otherCategories.length)];
            final rivalOld = marketValues[rival] ?? 10;
            marketValues[rival] = (rivalOld + drop)
                .clamp(GameConstants.minMarketValue, GameConstants.maxMarketValue);
          }
        }

        // Seçim sayısını güncelle ve kilitleme kontrolü yap
        final updatedPickCounts = Map<String, int>.from(game.categoryPickCounts);
        final newPickCount = (updatedPickCounts[category] ?? 0) + 1;
        updatedPickCounts[category] = newPickCount;

        final updatedLocked = List<String>.from(game.lockedCategories);
        if (newPickCount >= GameConstants.lockThreshold) {
          if (!updatedLocked.contains(category)) {
            updatedLocked.add(category);
          }
        }

        final updates = <String, dynamic>{
          'categoryMarketValues': marketValues,
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
}
