import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/user_provider.dart';
import '../data/firebase_room_source.dart';
import '../domain/room_entity.dart';
import '../domain/room_repository.dart';
import '../../../shared/models/enums.dart';

part 'room_provider.g.dart';

@Riverpod(keepAlive: true)
RoomRepository roomRepository(Ref ref) {
  return FirebaseRoomSource();
}

@Riverpod(keepAlive: true)
Stream<RoomEntity?> watchRoom(Ref ref, String roomCode) {
  return ref.watch(roomRepositoryProvider).watchRoom(roomCode);
}

@Riverpod(keepAlive: true)
Stream<List<PlayerEntity>> watchPlayers(Ref ref, String roomCode) {
  return ref.watch(roomRepositoryProvider).watchPlayers(roomCode);
}

@Riverpod(keepAlive: true)
class RoomController extends _$RoomController {
  @override
  FutureOr<String?> build() => null;

  Future<String> createRoom({
    required String hostId,
    required String hostName,
    required EndConditionType endConditionType,
    required int endConditionValue,
    required RoomVisibility visibility,
    required GamePreset preset,
    required GameMode mode,
  }) async {
    state = const AsyncLoading();
    
    // E20: Get user profile to attach avatarUrl
    final userProfile = await ref.read(userRepositoryProvider).getUserProfile(hostId);
    
    final result = await AsyncValue.guard(() =>
      ref.read(roomRepositoryProvider).createRoom(
        hostId: hostId,
        hostName: hostName,
        hostAvatarUrl: userProfile?.avatarUrl,
        endConditionType: endConditionType,
        endConditionValue: endConditionValue,
        visibility: visibility,
        preset: preset,
        mode: mode,
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

  Future<void> toggleVisibility({
    required String roomCode,
    required RoomVisibility visibility,
  }) async {
    await ref.read(roomRepositoryProvider).toggleVisibility(
      roomCode: roomCode,
      visibility: visibility,
    );
  }

  Future<void> startGame(String roomCode) async {
    await ref.read(roomRepositoryProvider).updateRoomStatus(
      roomCode: roomCode,
      status: GameStatus.playing,
    );
  }
}
