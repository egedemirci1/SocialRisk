import 'room_entity.dart';
import '../../../shared/models/enums.dart';

abstract class RoomRepository {
  Future<String> createRoom({
    required String hostId,
    required String hostName,
    String? hostAvatarUrl,
    required EndConditionType endConditionType,
    required int endConditionValue,
    required RoomVisibility visibility,
    required GameDifficulty difficulty,
  });

  Future<void> joinRoom({
    required String roomCode,
    required String playerId,
    required String playerName,
    String? playerAvatarUrl,
  });

  Future<void> leaveRoom({
    required String roomCode,
    required String playerId,
  });

  Stream<RoomEntity?> watchRoom(String roomCode);

  Stream<List<PlayerEntity>> watchPlayers(String roomCode);

  Future<void> toggleReady({
    required String roomCode,
    required String playerId,
    required bool isReady,
  });

  Future<void> toggleVisibility({
    required String roomCode,
    required RoomVisibility visibility,
  });

  Future<void> updateRoomStatus({
    required String roomCode,
    required GameStatus status,
  });

  Future<bool> doesRoomExist(String roomCode);
}
