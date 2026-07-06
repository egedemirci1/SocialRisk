import '../../features/room/domain/room_entity.dart';
import '../../shared/models/enums.dart';

/// Oda / oyun durumuna göre devam rotası.
class GameRouteResolver {
  GameRouteResolver._();

  static String? routeForRoom(RoomEntity room) {
    if (room.status == GameStatus.waiting) {
      return '/lobby';
    }

    final gameId = room.gameId;
    if (gameId == null || gameId.isEmpty) {
      return '/lobby';
    }

    return routeForGameStatus(
      room.status,
      mode: room.mode,
      gameId: gameId,
      roomCode: room.roomCode,
    );
  }

  static String? routeForGameStatus(
    GameStatus status, {
    required GameMode mode,
    required String gameId,
    required String roomCode,
  }) {
    switch (status) {
      case GameStatus.waiting:
        return '/lobby';
      case GameStatus.playing:
        return mode == GameMode.economy ? '/economy-pick' : '/task';
      case GameStatus.choosingDifficulty:
        return '/difficulty';
      case GameStatus.performing:
        return '/performing';
      case GameStatus.voting:
        return '/voting';
      case GameStatus.results:
        return '/round-result';
      case GameStatus.finished:
        return '/game-over';
    }
  }

  static Object? extraForRoom(RoomEntity room, {GameStatus? gameStatus}) {
    final status = gameStatus ?? room.status;

    if (status == GameStatus.waiting) {
      return room.roomCode;
    }
    if (status == GameStatus.finished) {
      return room.roomCode;
    }

    final gameId = room.gameId;
    if (gameId == null || gameId.isEmpty) {
      return room.roomCode;
    }

    return {'gameId': gameId, 'roomCode': room.roomCode};
  }

  static String resolveRoute(RoomEntity room, {GameStatus? gameStatus}) {
    final status = gameStatus ?? room.status;
    final gameId = room.gameId;

    if (status == GameStatus.waiting || gameId == null || gameId.isEmpty) {
      return '/lobby';
    }

    return routeForGameStatus(
          status,
          mode: room.mode,
          gameId: gameId,
          roomCode: room.roomCode,
        ) ??
        '/lobby';
  }
}
