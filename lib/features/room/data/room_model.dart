import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/enums.dart';
import '../domain/room_entity.dart';

class RoomModel {
  final String roomCode;
  final String hostId;
  final String mode;
  final String status;
  final String endConditionType;
  final int endConditionValue;
  final String visibility;
  final String? gameId;
  final DateTime createdAt;

  const RoomModel({
    required this.roomCode,
    required this.hostId,
    required this.mode,
    required this.status,
    required this.endConditionType,
    required this.endConditionValue,
    this.visibility = 'open',
    this.gameId,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomCode: json['roomCode'] as String,
      hostId: json['hostId'] as String,
      mode: json['mode'] as String? ?? 'classic',
      status: json['status'] as String? ?? 'waiting',
      endConditionType: json['endConditionType'] as String? ?? 'score',
      endConditionValue: json['endConditionValue'] as int? ?? 5000,
      visibility: json['visibility'] as String? ?? 'open',
      gameId: json['gameId'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'hostId': hostId,
      'mode': mode,
      'status': status,
      'endConditionType': endConditionType,
      'endConditionValue': endConditionValue,
      'visibility': visibility,
      'gameId': gameId,
      'createdAt': FieldValue.serverTimestamp(),
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
      gameId: gameId,
      players: players,
      createdAt: createdAt,
    );
  }
}

class PlayerModel {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final int score;
  final int passStreak;
  final bool isReady;

  const PlayerModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.score = 0,
    this.passStreak = 0,
    this.isReady = false,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json, String docId) {
    return PlayerModel(
      id: docId,
      displayName: json['displayName'] as String? ?? 'Oyuncu',
      avatarUrl: json['avatarUrl'] as String?,
      score: json['score'] as int? ?? 0,
      passStreak: json['passStreak'] as int? ?? 0,
      isReady: json['isReady'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'score': score,
      'passStreak': passStreak,
      'isReady': isReady,
    };
  }

  PlayerEntity toEntity() {
    return PlayerEntity(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
      score: score,
      passStreak: passStreak,
      isReady: isReady,
    );
  }
}
