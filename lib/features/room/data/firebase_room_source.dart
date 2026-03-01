import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/room_entity.dart';
import '../domain/room_repository.dart';
import 'room_model.dart';
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
    required EndConditionType endConditionType,
    required int endConditionValue,
    required RoomVisibility visibility,
    required GameDifficulty difficulty,
  }) async {
    String roomCode = AppHelpers.generateRoomCode();

    // Kodun benzersiz olduğunu kontrol et
    while (await doesRoomExist(roomCode)) {
      roomCode = AppHelpers.generateRoomCode();
    }

    final roomModel = RoomModel(
      roomCode: roomCode,
      hostId: hostId,
      mode: GameMode.classic.name,
      status: GameStatus.waiting.name,
      endConditionType: endConditionType.name,
      endConditionValue: endConditionValue,
      visibility: visibility.name,
      difficulty: difficulty.name,
      createdAt: DateTime.now(),
    );

    await _roomDoc(roomCode).set(roomModel.toJson());

    // Host'u oyuncu olarak ekle
    final hostPlayer = PlayerModel(
      id: hostId,
      displayName: hostName,
      avatarUrl: hostAvatarUrl,
      isReady: true,
    );
    await _playersRef(roomCode).doc(hostId).set(hostPlayer.toJson());

    return roomCode;
  }

  @override
  Future<void> joinRoom({
    required String roomCode,
    required String playerId,
    required String playerName,
    String? playerAvatarUrl,
  }) async {
    final roomDoc = await _roomDoc(roomCode).get();
    if (!roomDoc.exists) {
      throw Exception('Oda bulunamadı: $roomCode');
    }

    final playersSnap = await _playersRef(roomCode).get();
    if (playersSnap.docs.length >= GameConstants.maxPlayers) {
      throw Exception('Oda dolu! Maksimum ${GameConstants.maxPlayers} oyuncu.');
    }

    final player = PlayerModel(
      id: playerId,
      displayName: playerName,
      avatarUrl: playerAvatarUrl,
    );
    await _playersRef(roomCode).doc(playerId).set(player.toJson());
  }

  @override
  Future<void> leaveRoom({
    required String roomCode,
    required String playerId,
  }) async {
    await _playersRef(roomCode).doc(playerId).delete();
  }

  @override
  Stream<RoomEntity?> watchRoom(String roomCode) {
    final roomStream = _roomDoc(roomCode).snapshots();
    final playersStream = _playersRef(roomCode).snapshots();

    return Rx.combineLatest2(
      roomStream,
      playersStream,
      (roomSnap, playersSnap) {
        if (!roomSnap.exists) return null;

        final roomModel = RoomModel.fromJson(roomSnap.data()!);
        final players = playersSnap.docs
            .map((doc) => PlayerModel.fromJson(doc.data(), doc.id).toEntity())
            .toList();

        return roomModel.toEntity(players);
      },
    );
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
    await _playersRef(roomCode).doc(playerId).update({'isReady': isReady});
  }

  @override
  Future<void> toggleVisibility({
    required String roomCode,
    required RoomVisibility visibility,
  }) async {
    await _roomDoc(roomCode).update({'visibility': visibility.name});
  }

  @override
  Future<void> updateRoomStatus({
    required String roomCode,
    required GameStatus status,
  }) async {
    await _roomDoc(roomCode).update({'status': status.name});
  }

  @override
  Future<bool> doesRoomExist(String roomCode) async {
    final doc = await _roomDoc(roomCode).get();
    return doc.exists;
  }
}
