import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/enums.dart';
import '../domain/room_entity.dart';

class RoomModel {
  final String roomCode;
  final String hostId;
  final String mode;
  final String status;
  final int playerCount;
  final String endConditionType;
  final int endConditionValue;
  final String visibility;
  final String? gameId;
  final List<String> categories;
  final bool useCustomDeck;
  final DateTime createdAt;
  final Map<String, LobbyEmoteModel> lobbyEmotes;

  const RoomModel({
    required this.roomCode,
    required this.hostId,
    required this.mode,
    required this.status,
    this.playerCount = 0,
    required this.endConditionType,
    required this.endConditionValue,
    this.visibility = 'open',
    this.categories = const [],
    this.useCustomDeck = false,
    this.gameId,
    required this.createdAt,
    this.lobbyEmotes = const {},
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final rawEmotes = (json['lobbyEmotes'] as Map<String, dynamic>?) ?? const {};
    return RoomModel(
      roomCode: json['roomCode'] as String,
      hostId: json['hostId'] as String,
      mode: json['mode'] as String? ?? 'classic',
      status: json['status'] as String? ?? 'waiting',
      playerCount: json['playerCount'] as int? ?? 0,
      endConditionType: json['endConditionType'] as String? ?? 'score',
      endConditionValue: json['endConditionValue'] as int? ?? 500,
      visibility: json['visibility'] as String? ?? 'open',
      categories: List<String>.from(json['categories'] ?? []),
      useCustomDeck: json['useCustomDeck'] as bool? ?? false,
      gameId: json['gameId'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lobbyEmotes: rawEmotes.map(
        (key, value) => MapEntry(
          key,
          LobbyEmoteModel.fromJson(Map<String, dynamic>.from(value as Map), key),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'hostId': hostId,
      'mode': mode,
      'status': status,
      'playerCount': playerCount,
      'endConditionType': endConditionType,
      'endConditionValue': endConditionValue,
      'visibility': visibility,
      'categories': categories,
      'useCustomDeck': useCustomDeck,
      'gameId': gameId,
      'createdAt': FieldValue.serverTimestamp(),
      'lobbyEmotes': {
        for (final entry in lobbyEmotes.entries) entry.key: entry.value.toJson(),
      },
    };
  }

  RoomEntity toEntity(List<PlayerEntity> players) {
    return RoomEntity(
      roomCode: roomCode,
      hostId: hostId,
      mode: GameMode.values.firstWhere(
        (e) => e.name == mode,
        orElse: () => GameMode.classic,
      ),
      status: GameStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => GameStatus.waiting,
      ),
      endConditionType: EndConditionType.values.firstWhere(
        (e) => e.name == endConditionType,
        orElse: () => EndConditionType.score,
      ),
      endConditionValue: endConditionValue,
      visibility: RoomVisibility.values.firstWhere(
        (e) => e.name == visibility,
        orElse: () => RoomVisibility.open,
      ),
      categories: categories,
      useCustomDeck: useCustomDeck,
      players: players,
      gameId: gameId,
      createdAt: createdAt,
      lobbyEmotes: lobbyEmotes.map(
        (key, value) => MapEntry(key, value.toEntity()),
      ),
    );
  }
}

class LobbyEmoteModel {
  final String playerId;
  final String emote;
  final DateTime sentAt;
  final DateTime expiresAt;

  const LobbyEmoteModel({
    required this.playerId,
    required this.emote,
    required this.sentAt,
    required this.expiresAt,
  });

  factory LobbyEmoteModel.fromJson(Map<String, dynamic> json, String playerId) {
    return LobbyEmoteModel(
      playerId: playerId,
      emote: json['emote'] as String? ?? '',
      sentAt: (json['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (json['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emote': emote,
      'sentAt': Timestamp.fromDate(sentAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  LobbyEmoteEntity toEntity() {
    return LobbyEmoteEntity(
      emote: emote,
      sentAt: sentAt,
      expiresAt: expiresAt,
    );
  }
}

class PlayerModel {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? activeFrame;
  final String? activeTitle;
  final String? lobbyEmote;
  final DateTime? lobbyEmoteExpiresAt;
  final int score;
  final int totalLikes;
  final int passStreak;
  final bool isReady;

  const PlayerModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.activeFrame,
    this.activeTitle,
    this.lobbyEmote,
    this.lobbyEmoteExpiresAt,
    this.score = 0,
    this.totalLikes = 0,
    this.passStreak = 0,
    this.isReady = false,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json, String docId) {
    return PlayerModel(
      id: docId,
      displayName: json['displayName'] as String? ?? 'Oyuncu',
      avatarUrl: json['avatarUrl'] as String?,
      activeFrame: json['activeFrame'] as String?,
      activeTitle: json['activeTitle'] as String?,
      lobbyEmote: json['lobbyEmote'] as String?,
      lobbyEmoteExpiresAt: (json['lobbyEmoteExpiresAt'] as Timestamp?)?.toDate(),
      score: json['score'] as int? ?? 0,
      totalLikes: json['totalLikes'] as int? ?? 0,
      passStreak: json['passStreak'] as int? ?? 0,
      isReady: json['isReady'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'activeFrame': activeFrame,
      'activeTitle': activeTitle,
      'lobbyEmote': lobbyEmote,
      'lobbyEmoteExpiresAt': lobbyEmoteExpiresAt == null
          ? null
          : Timestamp.fromDate(lobbyEmoteExpiresAt!),
      'score': score,
      'totalLikes': totalLikes,
      'passStreak': passStreak,
      'isReady': isReady,
    };
  }

  PlayerEntity toEntity() {
    return PlayerEntity(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
      activeFrame: activeFrame,
      activeTitle: activeTitle,
      lobbyEmote: lobbyEmote,
      lobbyEmoteExpiresAt: lobbyEmoteExpiresAt,
      score: score,
      totalLikes: totalLikes,
      passStreak: passStreak,
      isReady: isReady,
    );
  }
}
