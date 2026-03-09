import '../../../shared/models/enums.dart';

class RoomEntity {
  final String roomCode;
  final String hostId;
  final GameMode mode;
  final GameStatus status;
  final EndConditionType endConditionType;
  final int endConditionValue;
  final RoomVisibility visibility;
  final List<PlayerEntity> players;
  final String? gameId;
  final List<String> categories;
  final bool useCustomDeck;
  final DateTime createdAt;
  final Map<String, LobbyEmoteEntity> lobbyEmotes;

  const RoomEntity({
    required this.roomCode,
    required this.hostId,
    this.mode = GameMode.classic,
    this.status = GameStatus.waiting,
    this.endConditionType = EndConditionType.score,
    this.endConditionValue = 5000,
    this.visibility = RoomVisibility.open,
    this.players = const [],
    this.categories = const [],
    this.useCustomDeck = false,
    this.gameId,
    required this.createdAt,
    this.lobbyEmotes = const {},
  });
}

class LobbyEmoteEntity {
  final String emote;
  final DateTime sentAt;
  final DateTime expiresAt;

  const LobbyEmoteEntity({
    required this.emote,
    required this.sentAt,
    required this.expiresAt,
  });
}

class PlayerEntity {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? activeFrame;
  final String? activeTitle;
  final String? lobbyEmote;
  final DateTime? lobbyEmoteExpiresAt;
  final int score;
  final int passStreak;
  final bool isReady;

  const PlayerEntity({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.activeFrame,
    this.activeTitle,
    this.lobbyEmote,
    this.lobbyEmoteExpiresAt,
    this.score = 0,
    this.passStreak = 0,
    this.isReady = false,
  });

  String get name => displayName;
}
