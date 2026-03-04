import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/game_entity.dart';
import '../domain/game_repository.dart';
import 'game_model.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/models/enums.dart';
import '../../../core/constants/game_constants.dart';
import '../../admin/data/task_firestore_source.dart';

class FirebaseGameSource implements GameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TaskFirestoreSource _taskSource = TaskFirestoreSource();
  final Random _random = Random();

  CollectionReference<Map<String, dynamic>> get _gamesRef =>
      _firestore.collection('games');

  DocumentReference<Map<String, dynamic>> _gameDoc(String gameId) =>
      _gamesRef.doc(gameId);

  @override
  Future<String> startGame({
    required String roomId,
    required List<String> playerIds,
    required GameMode mode,
    List<String> categories = const [],
  }) async {
    try {
      // Sırayı karıştır
      final shuffled = List<String>.from(playerIds)..shuffle(_random);

      // Kullanılacak kategorileri belirle (boşsa varsayılanları kullan)
      final activeCategories = categories.isNotEmpty
          ? categories
          : GameConstants.defaultMarketValues.keys.toList();

      final marketValues = {
        for (var cat in activeCategories)
          cat: GameConstants.defaultMarketValues[cat] ?? 2,
      };

      final gameModel = GameModel(
        gameId: '',
        roomId: roomId,
        currentRound: 1,
        currentPlayerId: shuffled.first,
        currentTask: null,
        turnOrder: shuffled,
        status: 'playing',
        mode: mode.name,
        categoryMarketValues: mode == GameMode.economy
            ? marketValues
            : const {},
        lockedCategories: const [],
        categoryPickOrder: mode == GameMode.economy ? shuffled : const [],
        currentPickIndex: 0,
      );

      final docRef = await _gamesRef.add(gameModel.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception(
        'Oyun başlatılırken bağlantı hatası oluştu: ${e.message}',
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
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
      difficulty: task.difficulty,
      multiplier: task.multiplier,
    );
    await _gameDoc(gameId).update({
      'currentTask': taskModel.toJson(),
      'usedTaskIds': FieldValue.arrayUnion([
        task.id,
      ]), // E15: Görevi kullanıldı olarak işaretle
      'spinningTarget': null,
    });
  }

  @override
  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  }) async {
    // Yeni akış: Kategori belirlendiğinde görev atanmaz. Zorluk seçimi beklenir.
    await _gameDoc(gameId).update({
      'selectedCategory': category,
      'status': 'choosingDifficulty',
      'spinningTarget': null,
    });
  }

  @override
  Future<void> chooseDifficulty({
    required String gameId,
    required String roomId,
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

      // Odanın preset bilgisini al
      final roomSnap = await _firestore.collection('rooms').doc(roomId).get();
      final preset = roomSnap.data()?['preset'] as String? ?? 'classic';
      final useCustomDeck = roomSnap.data()?['useCustomDeck'] as bool? ?? false;
      final hostId = roomSnap.data()?['hostId'] as String?;

      // Firestore'dan görev çek
      final taskEntity = await _taskSource.getRandomTask(
        category: category,
        difficulty: difficulty,
        preset: preset,
        usedTaskIds: game.usedTaskIds,
        includeCustomDeck: useCustomDeck,
        hostId: hostId,
      );

      if (taskEntity == null) {
        // Çok düşük ihtimal: Hiç görev yok
        throw Exception('Bu kategoride görev bulunamadı!');
      }

      // Görevin çarpanını seçilen zorluğa göre ayarla
      final multiplier = difficulty == 'easy'
          ? 1
          : (difficulty == 'medium' ? 2 : 3);

      final taskModel = TaskModel(
        id: taskEntity.id,
        category: taskEntity.category,
        content: taskEntity.content,
        difficulty: taskEntity.difficulty,
        multiplier: multiplier,
      );

      await _gameDoc(gameId).update({
        'selectedDifficulty': difficulty,
        'currentTask': taskModel.toJson(),
        'usedTaskIds': FieldValue.arrayUnion([taskEntity.id]),
        'status':
            'playing', // Veya direkt performing? Gösterim task_screen'de halledilebilir.
      });
    } on FirebaseException catch (e) {
      throw Exception('Görev seçilirken bağlantı hatası oluştu: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
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
      'currentTask': null, // Çark çevrilecek
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

  // ── Faz 10: Ekonomi Modu ───────────────────────────────

  @override
  Future<void> initEconomyRound({
    required String gameId,
    required String roomId,
  }) async {
    // Oyuncuları puana göre sırala (yüksekten düşüğe)
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

        // Kilitlenen kategori seçilemez
        if (game.lockedCategories.contains(category)) {
          throw Exception('Bu kategori kilitli!');
        }

        // Pazar değerini düşür
        final updatedMarket = Map<String, int>.from(game.categoryMarketValues);
        final currentValue = updatedMarket[category] ?? 1;
        final newValue = (currentValue - GameConstants.marketDecayAmount).clamp(
          1,
          10,
        );
        updatedMarket[category] = newValue;

        // Seçim sayısını takip et ve kilitle
        final defaultVal = GameConstants.defaultMarketValues[category] ?? 1;
        final timesSelected = defaultVal - newValue + 1;
        final updatedLocked = List<String>.from(game.lockedCategories);
        if (timesSelected >= GameConstants.lockThreshold) {
          updatedLocked.add(category);
        }

        // Sonraki seçiciyi belirle
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

  // _getRandomTask ve seedData kullanımı kaldırıldı.
}
