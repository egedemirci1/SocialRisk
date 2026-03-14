import 'package:social_risk/features/room/domain/room_entity.dart';
import 'package:social_risk/features/room/domain/room_repository.dart';
import 'package:social_risk/shared/models/enums.dart';

/// Test için RoomRepository — createRoom sahte kod döndürür, diğerleri no-op.
class FakeRoomRepository implements RoomRepository {
  FakeRoomRepository({this.createdRoomCode = 'FAKE01'});

  final String createdRoomCode;

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
  }) async => createdRoomCode;

  @override
  Future<void> joinRoom({
    required String roomCode,
    required String playerId,
    required String playerName,
    String? playerAvatarUrl,
    String? activeFrame,
    String? activeTitle,
  }) async {}

  @override
  Future<void> leaveRoom({required String roomCode, required String playerId}) async {}

  @override
  Stream<RoomEntity?> watchRoom(String roomCode) =>
      Stream.value(RoomEntity(roomCode: roomCode, hostId: 'host', createdAt: DateTime(2024, 1, 1)));

  @override
  Stream<List<PlayerEntity>> watchPlayers(String roomCode) =>
      Stream.value([PlayerEntity(id: 'host', displayName: 'Host', isReady: true)]);

  @override
  Future<void> toggleReady({
    required String roomCode,
    required String playerId,
    required bool isReady,
  }) async {}

  @override
  Future<void> sendLobbyEmote({
    required String roomCode,
    required String playerId,
    required String emote,
  }) async {}

  @override
  Future<void> toggleVisibility({
    required String roomCode,
    required RoomVisibility visibility,
  }) async {}

  @override
  Future<void> updateRoomStatus({
    required String roomCode,
    required GameStatus status,
  }) async {}

  @override
  Future<bool> doesRoomExist(String roomCode) async => true;

  @override
  Future<String> startGameInRoom({
    required String roomCode,
    required List<String> playerIds,
    required GameMode mode,
    List<String> categories = const [],
  }) async => 'game-${roomCode}';

  @override
  Future<void> cleanupZombieRoomsAndGames() async {}
}
