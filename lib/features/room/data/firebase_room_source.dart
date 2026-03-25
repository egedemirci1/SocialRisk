import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/models/enums.dart';
import '../../admin/data/task_firestore_source.dart';
import '../../game/domain/game_repository.dart';
import '../domain/room_entity.dart';
import '../domain/room_repository.dart';
import 'room_model.dart';

class FirebaseRoomSource implements RoomRepository {
  final FirebaseFirestore _firestore;
  final TaskFirestoreSource _taskSource;
  final GameRepository? _gameRepository;

  FirebaseRoomSource({
    FirebaseFirestore? firestore,
    TaskFirestoreSource? taskSource,
    GameRepository? gameRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _taskSource = taskSource ?? TaskFirestoreSource(),
        _gameRepository = gameRepository;

  CollectionReference<Map<String, dynamic>> get _roomsRef =>
      _firestore.collection('rooms');

  DocumentReference<Map<String, dynamic>> _roomDoc(String roomCode) =>
      _roomsRef.doc(roomCode);

  CollectionReference<Map<String, dynamic>> _playersRef(String roomCode) =>
      _roomDoc(roomCode).collection('players');

  Future<void> _deleteRoomAndRelatedData(
    String roomCode,
    Map<String, dynamic>? roomData,
  ) async {
    try {
      final batch = _firestore.batch();
      
      // Oyunlar Cloud Functions tarafindan silindigi icin client'ta games dokumanini silmiyoruz. (firestore.rules allow delete: if false)
      
      final playersSnap = await _playersRef(roomCode).get();
      for (final doc in playersSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_roomDoc(roomCode));
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Oda silinirken hata (roomCode=$roomCode): $e');
      }
    }
  }

  @override
  Future<String> createRoom({
    required String hostId,
    required String hostName,
    String? hostAvatarUrl,
    String? hostActiveFrame,
    String? hostActiveTitle,
    required EndConditionType endConditionType,
    required int endConditionValue,
    required RoomVisibility visibility,
    required List<String> categories,
    required GameMode mode,
    required bool useCustomDeck,
  }) async {
    try {
      String roomCode = AppHelpers.generateRoomCode();
      while (await doesRoomExist(roomCode)) {
        roomCode = AppHelpers.generateRoomCode();
      }

      final roomModel = RoomModel(
        roomCode: roomCode,
        hostId: hostId,
        mode: mode.name,
        status: GameStatus.waiting.name,
        endConditionType: endConditionType.name,
        endConditionValue: endConditionValue,
        visibility: visibility.name,
        categories: categories,
        useCustomDeck: useCustomDeck,
        createdAt: DateTime.now(),
      );

      await _roomDoc(roomCode).set(roomModel.toJson());

      final hostPlayer = PlayerModel(
        id: hostId,
        displayName: hostName,
        avatarUrl: hostAvatarUrl,
        activeFrame: hostActiveFrame,
        activeTitle: hostActiveTitle,
        isReady: true,
      );
      await _playersRef(roomCode).doc(hostId).set(hostPlayer.toJson());

      return roomCode;
    } on FirebaseException catch (e) {
      throw Exception(
        'Oda oluşturulurken bağlantı hatası oluştu: ${e.message}',
      );
    } catch (e) {
      throw Exception('Oda oluşturulamadı: $e');
    }
  }

  @override
  Future<void> joinRoom({
    required String roomCode,
    required String playerId,
    required String playerName,
    String? playerAvatarUrl,
    String? activeFrame,
    String? activeTitle,
  }) async {
    try {
      final roomDoc = await _roomDoc(roomCode).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı: $roomCode');
      }

      final playersCountSnap = await _playersRef(roomCode).count().get();
      if (playersCountSnap.count! >= GameConstants.maxPlayers) {
        throw Exception(
          'Oda dolu! Maksimum ${GameConstants.maxPlayers} oyuncu.',
        );
      }

      final player = PlayerModel(
        id: playerId,
        displayName: playerName,
        avatarUrl: playerAvatarUrl,
        activeFrame: activeFrame,
        activeTitle: activeTitle,
      );
      await _playersRef(roomCode).doc(playerId).set(player.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Odaya katılırken bağlantı hatası oluştu: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> leaveRoom({
    required String roomCode,
    required String playerId,
  }) async {
    try {
      final roomSnap = await _roomDoc(roomCode).get();
      if (!roomSnap.exists) return;

      final roomData = roomSnap.data()!;
      final isHost = roomData['hostId'] == playerId;

      if (isHost) {
        await _deleteRoomAndRelatedData(roomCode, roomData);
        return;
      }

      await _playersRef(roomCode).doc(playerId).delete();

      final playersCountSnap = await _playersRef(roomCode).count().get();
      final count = playersCountSnap.count ?? 0;
      if (count == 0) {
        await _deleteRoomAndRelatedData(roomCode, roomData);
      } else {
        final gameId = roomData['gameId'] as String?;
        if (gameId != null &&
            gameId.isNotEmpty &&
            _gameRepository != null) {
          await _gameRepository!.removePlayerFromGame(
            gameId: gameId,
            playerId: playerId,
          );
        }
      }
    } on FirebaseException catch (e) {
      throw Exception('Odadan ayrılırken hata oluştu: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Odadan ayrilirken hata: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<RoomEntity?> watchRoom(String roomCode) {
    final roomStream = _roomDoc(roomCode).snapshots();
    final playersStream = _playersRef(roomCode).snapshots();

    return Rx.combineLatest2(roomStream, playersStream, (roomSnap, playersSnap) {
      if (!roomSnap.exists) return null;

      final roomModel = RoomModel.fromJson(roomSnap.data()!);
      final players = playersSnap.docs
          .map((doc) => PlayerModel.fromJson(doc.data(), doc.id).toEntity())
          .toList();

      return roomModel.toEntity(players);
    });
  }

  @override
  Stream<List<PlayerEntity>> watchPlayers(String roomCode) {
    return _playersRef(roomCode).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PlayerModel.fromJson(doc.data(), doc.id).toEntity())
          .toList();
    });
  }

  @override
  Future<void> toggleReady({
    required String roomCode,
    required String playerId,
    required bool isReady,
  }) async {
    try {
      await _playersRef(roomCode).doc(playerId).update({'isReady': isReady});
    } on FirebaseException catch (e) {
      throw Exception('Hazır durumu güncellenirken hata oluştu: ${e.message}');
    }
  }

  @override
  Future<void> sendLobbyEmote({
    required String roomCode,
    required String playerId,
    required String emote,
  }) async {
    const cooldown = Duration(seconds: 3);
    const visibility = Duration(seconds: 4);

    try {
      await _firestore.runTransaction((transaction) async {
        final roomRef = _roomDoc(roomCode);
        final roomSnap = await transaction.get(roomRef);
        if (!roomSnap.exists) {
      if (!roomSnap.exists) throw Exception('Oda bulunamadı!');
        }

        final roomData = roomSnap.data() ?? <String, dynamic>{};
        final rawLobbyEmotes =
            Map<String, dynamic>.from(roomData['lobbyEmotes'] as Map? ?? const {});
        final now = DateTime.now();
        final currentPlayerEmote = rawLobbyEmotes[playerId] as Map<String, dynamic>?;
        final lastSentAt = (currentPlayerEmote?['sentAt'] as Timestamp?)?.toDate();

        if (lastSentAt != null && now.difference(lastSentAt) < cooldown) {
          final remaining = cooldown - now.difference(lastSentAt);
          throw Exception('Cooldown:${remaining.inSeconds + 1}');
        }

        rawLobbyEmotes.removeWhere((key, value) {
          if (value is! Map) return true;
          final expiresAt = (value['expiresAt'] as Timestamp?)?.toDate();
          return expiresAt == null || expiresAt.isBefore(now);
        });

        rawLobbyEmotes[playerId] = {
          'emote': emote,
          'sentAt': Timestamp.fromDate(now),
          'expiresAt': Timestamp.fromDate(now.add(visibility)),
        };

        transaction.update(roomRef, {'lobbyEmotes': rawLobbyEmotes});
      });
    } on FirebaseException catch (e) {
      throw Exception('Emote gönderilirken hata oluştu: ${e.message}');
    }
  }

  @override
  Future<void> toggleVisibility({
    required String roomCode,
    required RoomVisibility visibility,
  }) async {
    try {
      await _roomDoc(roomCode).update({'visibility': visibility.name});
    } on FirebaseException catch (e) {
      throw Exception('Oda görünürlüğü güncellenirken hata oluştu: ${e.message}');
    }
  }

  @override
  Future<void> updateRoomStatus({
    required String roomCode,
    required GameStatus status,
  }) async {
    try {
      await _roomDoc(roomCode).update({'status': status.name});
    } on FirebaseException catch (e) {
      throw Exception('Oda durumu güncellenirken hata oluştu: ${e.message}');
    }
  }

  @override
  Future<String> startGameInRoom({
    required String roomCode,
    required List<String> playerIds,
    required GameMode mode,
    List<String> categories = const [],
  }) async {
    try {
      final roomRef = _roomDoc(roomCode);

      final roomSnap = await roomRef.get();
      if (!roomSnap.exists) throw Exception('Oda bulunamadı!');
      final roomData = roomSnap.data()!;
      final categoriesList = List<String>.from(roomData['categories'] ?? []);
      final useCustomDeck = roomData['useCustomDeck'] as bool? ?? false;
      final hostId = roomData['hostId'] as String?;

      final activeCategories = categories.isNotEmpty
          ? categories
          : (categoriesList.isNotEmpty
              ? categoriesList
              : GameConstants.defaultMarketValues.keys.toList());

      final taskPool = await _taskSource.fetchTaskPool(
        includeCustomDeck: useCustomDeck,
        hostId: hostId,
        categories: activeCategories,
      );

      return await _firestore.runTransaction((transaction) async {
        final freshRoomSnap = await transaction.get(roomRef);
    if (!freshRoomSnap.exists) throw Exception('Oda bulunamadı!');

        final gameRef = _firestore.collection('games').doc();
        final gameId = gameRef.id;
        final playersList = List<String>.from(playerIds)..shuffle();

        final marketValues = mode == GameMode.economy
            ? {
                for (var cat in activeCategories)
                  cat: GameConstants.defaultMarketValues[cat] ?? 2,
              }
            : <String, int>{};

        final gameModel = {
          'gameId': gameId,
          'roomId': roomCode,
          'currentRound': 1,
          'currentPlayerId': playersList.first,
          'status': 'playing',
          'mode': mode.name,
          'turnOrder': playersList,
          'usedTaskIds': [],
          'categoryMarketValues': marketValues,
          'lockedCategories': [],
          'categoryPickOrder': mode == GameMode.economy ? playersList : [],
          'currentPickIndex': 0,
          'taskPool': taskPool,
          'createdAt': FieldValue.serverTimestamp(),
        };

        transaction.set(gameRef, gameModel);
        transaction.update(roomRef, {
          'status': GameStatus.playing.name,
          'gameId': gameId,
        });

        return gameId;
      });
    } on FirebaseException catch (e) {
      throw Exception('Oyun başlatılamadı (İşlem Hatası): ${e.message}');
    } catch (e) {
      throw Exception('Oyun başlatılamadı: $e');
    }
  }

  @override
  Future<bool> doesRoomExist(String roomCode) async {
    try {
      final doc = await _roomDoc(roomCode).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> cleanupZombieRoomsAndGames() async {
    try {
      final now = DateTime.now();
      final thresholdDate = now.subtract(const Duration(hours: 24));

      QuerySnapshot<Map<String, dynamic>>? zombieRoomsQuery;
      try {
        zombieRoomsQuery = await _roomsRef
            .where('createdAt', isLessThan: Timestamp.fromDate(thresholdDate))
            .get();
      } catch (_) {
        return;
      }

      if (zombieRoomsQuery.docs.isEmpty) return;

      WriteBatch batch = _firestore.batch();
      int operationCount = 0;

      for (final doc in zombieRoomsQuery.docs) {
        // Oyunlar (games) kural gereği istemci tarafından silinmediğinden atlanıyor.
        final playersSnap = await _playersRef(doc.id).get();
        for (final playerDoc in playersSnap.docs) {
          batch.delete(playerDoc.reference);
          operationCount++;

          if (operationCount >= 450) {
            await batch.commit();
            batch = _firestore.batch();
            operationCount = 0;
          }
        }

        batch.delete(doc.reference);
        operationCount++;

        if (operationCount >= 450) {
          await batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      debugPrint('${zombieRoomsQuery.docs.length} zombi oda temizlendi.');
    } catch (e) {
      debugPrint('Zombi odaları temizlerken hata oluştu: $e');
    }
  }
}
