import 'room_entity.dart';
import '../../../shared/models/enums.dart';

abstract class RoomRepository {
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
  });

  Future<void> joinRoom({
    required String roomCode,
    required String playerId,
    required String playerName,
    String? playerAvatarUrl,
    String? activeFrame,
    String? activeTitle,
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
