part of 'firebase_game_source.dart';

Future<void> _fgsAssignTaskByCategory(
  FirebaseGameSource source, {
  required String gameId,
  required String category,
}) async {

    // Basit test
    if (gameId.isEmpty) throw Exception('GameId empty');
    if (category.isEmpty) throw Exception('Category empty');
      
    try {
      final gameDocRef = source._gameDoc(gameId);
      
      // Transaction öncesi game state'i kontrol et
      final preGameSnap = await gameDocRef.get();
      if (!preGameSnap.exists) {
        return;
      }
      
      final preGame = GameModel.fromJson(preGameSnap.data()!, gameId);

      await source._firestore.runTransaction((transaction) async {
        final snap = await transaction.get(gameDocRef);
        
        if (!snap.exists) {
          return;
        }

        final game = GameModel.fromJson(snap.data()!, snap.id);

        // Race condition önleme: Eğer zaten task seçilmişse işlemi iptal et
        if (game.currentTask != null) {
          return;
        }

        // Economy modunda kategori seçimi validation
        if (game.categoryPickOrder.isNotEmpty) {
          final expectedPlayer = game.categoryPickOrder[game.currentPickIndex];
          if (game.currentPlayerId != expectedPlayer) {
            // Sadece sırası gelen oyuncu kategori seçebilir
            return;
          }
        }

        final poolKey = '${category}_mixed';
        final pool = game.taskPool[poolKey] ?? [];

        // Eğer mixed mode boşsa, individual difficulty'ları dene
        if (pool.isEmpty) {
          final easyPool = game.taskPool['${category}_easy'] ?? [];
          final mediumPool = game.taskPool['${category}_medium'] ?? [];
          final hardPool = game.taskPool['${category}_hard'] ?? [];
          
          // Tüm zorlukları birleştir
          final allTasks = [...easyPool, ...mediumPool, ...hardPool];
          if (allTasks.isNotEmpty) {
            final available = allTasks
                .where((t) => !game.usedTaskIds.contains(t['id']))
                .toList();
            
            Map<String, dynamic>? selectedTask;
            if (available.isNotEmpty) {
              selectedTask = available[source._random.nextInt(available.length)];
            } else {
              selectedTask = allTasks[source._random.nextInt(allTasks.length)];
            }

            if (selectedTask != null) {
              final taskModel = TaskModel(
                id: selectedTask['id']?.toString() ?? '',
                category: selectedTask['category']?.toString() ?? category,
                content: selectedTask['content']?.toString() ?? '',
                difficulty: selectedTask['difficulty']?.toString() ?? 'medium',
                multiplier: 2, // Mixed modda sabit 2x
              );

              final updates = <String, dynamic>{
                'selectedCategory': category,
                'currentTask': taskModel.toJson(),
                'usedTaskIds': FieldValue.arrayUnion([taskModel.id]),
                'status': 'choosingDifficulty',
              };

              transaction.update(gameDocRef, updates);
              return;
            }
          }
        }

        final available = pool
            .where((t) => !game.usedTaskIds.contains(t['id']))
            .toList();

        Map<String, dynamic>? selectedTask;

        if (available.isNotEmpty) {
          selectedTask = available[source._random.nextInt(available.length)];
        } else if (pool.isNotEmpty) {
          selectedTask = pool[source._random.nextInt(pool.length)];
        }

        if (selectedTask == null) {
          throw const AppException(AppErrorCode.noTasksInCategory);
        }

        final taskModel = TaskModel(
          id: selectedTask['id']?.toString() ?? '',
          category: selectedTask['category']?.toString() ?? category,
          content: selectedTask['content']?.toString() ?? '',
          difficulty: selectedTask['difficulty']?.toString() ?? 'medium',
          multiplier: 2, // Mixed modda sabit 2x
        );

        final updates = <String, dynamic>{
          'selectedCategory': category,
          'currentTask': taskModel.toJson(),
          'usedTaskIds': FieldValue.arrayUnion([taskModel.id]),
          'status': 'choosingDifficulty',
        };

        transaction.update(gameDocRef, updates);
      });
    } on FirebaseException catch (e) {
      throw AppException(
        AppErrorCode.assignCategoryConnectionError,
        {'message': e.message ?? ''},
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppErrorCode.assignCategoryConnectionError, {
        'message': e.toString().replaceAll('Exception: ', ''),
      });
    }

}

Future<void> _fgsPassTask(
  FirebaseGameSource source, {
  required String gameId,
  required String roomId,
  required String playerId,
  required int basePenalty,
}) async {

    try {
      final playerDocRef = source._firestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(playerId);
      final gameDocRef = source._gameDoc(gameId);

      await source._firestore.runTransaction((transaction) async {
        final playerSnap = await transaction.get(playerDocRef);
        final gameSnap = await transaction.get(gameDocRef);
        if (!gameSnap.exists || gameSnap.data() == null) {
          throw const AppException(AppErrorCode.gameNotFound);
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
          'lastRoundAudienceScore': 0,
          'lastRoundMultiplier': 0,
          'lastRoundPlayerId': playerId,
        };

        source._applyEconomyRoundAdvance(
          game,
          updates,
          selectedCategory: game.selectedCategory,
        );

        transaction.update(gameDocRef, updates);
      });
    } on FirebaseException catch (e) {
      throw AppException(
        AppErrorCode.skipTaskError,
        {'message': e.message ?? ''},
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        AppErrorCode.skipTaskUnexpectedError,
        {'error': e.toString()},
      );
    }

}
