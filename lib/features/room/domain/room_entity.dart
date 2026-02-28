import '../../../shared/models/enums.dart';

class RoomEntity {
  final String roomCode;
  final String hostId;
  final GameMode mode;
  final GameStatus status;
  final EndConditionType endConditionType;
  final int endConditionValue;
  final List<PlayerEntity> players;
  final DateTime createdAt;

  const RoomEntity({
    required this.roomCode,
    required this.hostId,
    this.mode = GameMode.classic,
    this.status = GameStatus.waiting,
    this.endConditionType = EndConditionType.score,
    this.endConditionValue = 5000,
    this.players = const [],
    required this.createdAt,
  });
}

class PlayerEntity {
  final String id;
  final String displayName;
  final int score;
  final int passStreak;
  final bool isReady;

  const PlayerEntity({
    required this.id,
    required this.displayName,
    this.score = 0,
    this.passStreak = 0,
    this.isReady = false,
  });

  /// Alias — ekran kodları `player.name` kullanıyor.
  String get name => displayName;
}
