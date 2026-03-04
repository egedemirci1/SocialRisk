import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/room_entity.dart';
import '../domain/room_repository.dart';
import 'room_model.dart';
import '../../admin/data/task_firestore_source.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/models/enums.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseRoomSource implements RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _roomsRef =>
      _firestore.collection('rooms');

  DocumentReference<Map<String, dynamic>> _roomDoc(String roomCode) =>
      _roomsRef.doc(roomCode);

  CollectionReference<Map<String, dynamic>> _playersRef(String roomCode) =>
      _roomDoc(roomCode).collection('players');

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
    required GamePreset preset,
    required GameMode mode,
    required bool useCustomDeck,
  }) async {
    try {
      String roomCode = AppHelpers.generateRoomCode();

      // Kodun benzersiz olduğunu kontrol et
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
        preset: preset.name,
        useCustomDeck: useCustomDeck,
        createdAt: DateTime.now(),
      );

      await _roomDoc(roomCode).set(roomModel.toJson());

      // Host'u oyuncu olarak ekle
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
      // 0. Oda bilgilerini al (Host kontrolü için)
      final roomSnap = await _roomDoc(roomCode).get();
      if (!roomSnap.exists) return; // Oda zaten silinmiş olabilir

      final roomData = roomSnap.data()!;
      final isHost = roomData['hostId'] == playerId;

      if (isHost) {
        // Eğer ayrılan kişi host ise, odayı ve içindekileri tamamen temizle
        final gameId = roomData['gameId'];

        final batch = _firestore.batch();

        if (gameId != null && gameId.toString().isNotEmpty) {
          batch.delete(_firestore.collection('games').doc(gameId));
        }

        // Oyuncular alt koleksiyonunu batch ile temizle
        final playersSnap = await _playersRef(roomCode).get();
        for (var doc in playersSnap.docs) {
          batch.delete(doc.reference);
        }

        batch.delete(_roomDoc(roomCode));
        await batch.commit();
        return;
      }

      // 1. Oyuncunun odadan ayrılması (Eğer host değilse)
      await _playersRef(roomCode).doc(playerId).delete();

      // 2. Kalan oyuncu sayısını kontrol et
      final playersCountSnap = await _playersRef(roomCode).count().get();
      if (playersCountSnap.count == 0 || playersCountSnap.count == null) {
        // Eğer odada kimse kalmadıysa odayı ve bağlı oyunu tamamen sil
        final gameId = roomData['gameId'];
        if (gameId != null && gameId.toString().isNotEmpty) {
          await _firestore.collection('games').doc(gameId).delete();
        }
        await _roomDoc(roomCode).delete();
      }
    } on FirebaseException catch (e) {
      throw Exception('Odadan ayrılırken hata oluştu: ${e.message}');
    }
  }

  @override
  Stream<RoomEntity?> watchRoom(String roomCode) {
    final roomStream = _roomDoc(roomCode).snapshots();
    final playersStream = _playersRef(roomCode).snapshots();

    return Rx.combineLatest2(roomStream, playersStream, (
      roomSnap,
      playersSnap,
    ) {
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
  Future<void> toggleVisibility({
    required String roomCode,
    required RoomVisibility visibility,
  }) async {
    try {
      await _roomDoc(roomCode).update({'visibility': visibility.name});
    } on FirebaseException catch (e) {
      throw Exception(
        'Oda görünürlüğü güncellenirken hata oluştu: ${e.message}',
      );
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

      // ─── Görev havuzunu önceden yükle (transaction dışında) ───
      final roomSnap = await roomRef.get();
      if (!roomSnap.exists) throw Exception('Oda bulunamadı!');
      final roomData = roomSnap.data()!;
      final preset = roomData['preset'] as String? ?? 'classic';
      final useCustomDeck = roomData['useCustomDeck'] as bool? ?? false;
      final hostId = roomData['hostId'] as String?;

      final activeCategories = categories.isNotEmpty
          ? categories
          : GameConstants.defaultMarketValues.keys.toList();

      final taskSource = TaskFirestoreSource();
      final taskPool = await taskSource.fetchTaskPool(
        preset: preset,
        includeCustomDeck: useCustomDeck,
        hostId: hostId,
        categories: activeCategories,
      );

      // ─── Atomik Transaction: Oda güncelle + Oyun oluştur ───
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
      throw Exception('Oyun başlatılamadı (Transaction Error): ${e.message}');
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
        // Regular users don't have permission to cleanup. Just ignore.
        return;
      }

      if (zombieRoomsQuery.docs.isEmpty) return;

      WriteBatch batch = _firestore.batch();
      int operationCount = 0;

      for (final doc in zombieRoomsQuery.docs) {
        final roomData = doc.data();
        final gameId = roomData['gameId'] as String?;

        // 1. Bağlı oyun dökümanını sil
        if (gameId != null && gameId.isNotEmpty) {
          batch.delete(_firestore.collection('games').doc(gameId));
          operationCount++;
        }

        // 2. Odanın "players" alt koleksiyonunu sil
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

        // 3. Odanın kendisini sil
        batch.delete(doc.reference);
        operationCount++;

        // Batch limit kontrolü (Firestore max 500)
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
