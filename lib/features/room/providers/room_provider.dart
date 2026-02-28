import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_room_source.dart';
import '../domain/room_entity.dart';
import '../domain/room_repository.dart';
import '../../../shared/models/enums.dart';

part 'room_provider.g.dart';

@riverpod
RoomRepository roomRepository(Ref ref) {
  return FirebaseRoomSource();
}

@riverpod
Stream<RoomEntity?> watchRoom(Ref ref, String roomCode) {
  return ref.watch(roomRepositoryProvider).watchRoom(roomCode);
}

@riverpod
Stream<List<PlayerEntity>> watchPlayers(Ref ref, String roomCode) {
  return ref.watch(roomRepositoryProvider).watchPlayers(roomCode);
}

@riverpod
class RoomController extends _$RoomController {
  @override
  FutureOr<String?> build() => null;

  Future<String> createRoom({
    required String hostId,
    required String hostName,
    required EndConditionType endConditionType,
    required int endConditionValue,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() =>
      ref.read(roomRepositoryProvider).createRoom(
        hostId: hostId,
        hostName: hostName,
        endConditionType: endConditionType,
        endConditionValue: endConditionValue,
      ),
    );
    state = result;
    return result.value ?? '';
  }

  Future<void> joinRoom({
    required String roomCode,
    required String playerId,
    required String playerName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(roomRepositoryProvider).joinRoom(
        roomCode: roomCode,
        playerId: playerId,
        playerName: playerName,
      );
      return roomCode;
    });
  }

  Future<void> leaveRoom({
    required String roomCode,
    required String playerId,
  }) async {
    await ref.read(roomRepositoryProvider).leaveRoom(
      roomCode: roomCode,
      playerId: playerId,
    );
    state = const AsyncData(null);
  }

  Future<void> toggleReady({
    required String roomCode,
    required String playerId,
    required bool isReady,
  }) async {
    await ref.read(roomRepositoryProvider).toggleReady(
      roomCode: roomCode,
      playerId: playerId,
      isReady: isReady,
    );
  }

  Future<void> startGame(String roomCode) async {
    await ref.read(roomRepositoryProvider).updateRoomStatus(
      roomCode: roomCode,
      status: GameStatus.playing,
    );
  }
}
