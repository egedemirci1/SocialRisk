import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/game_entity.dart';
import '../../../shared/models/enums.dart';

class GameModel {
  final String gameId;
  final String roomId;
  final int currentRound;
  final String currentPlayerId;
  final Map<String, dynamic>? currentTask;
  final List<String> turnOrder;
  final String status;
  final List<String> usedTaskIds;
  final String? spinningTarget;
  final String difficulty;
  final int? lastRoundScore;
  final int? lastRoundMultiplier;

  const GameModel({
    required this.gameId,
    required this.roomId,
    this.currentRound = 1,
    required this.currentPlayerId,
    this.currentTask,
    required this.turnOrder,
    this.status = 'playing',
    this.usedTaskIds = const [],
    this.spinningTarget,
    this.difficulty = 'mixed',
    this.lastRoundScore,
    this.lastRoundMultiplier,
  });

  factory GameModel.fromJson(Map<String, dynamic> json, String docId) {
    return GameModel(
      gameId: docId,
      roomId: json['roomId'] as String,
      currentRound: json['currentRound'] as int? ?? 1,
      currentPlayerId: json['currentPlayerId'] as String,
      currentTask: json['currentTask'] as Map<String, dynamic>?,
      turnOrder: List<String>.from(json['turnOrder'] ?? []),
      status: json['status'] as String? ?? 'playing',
      usedTaskIds: List<String>.from(json['usedTaskIds'] ?? []),
      spinningTarget: json['spinningTarget'] as String?,
      difficulty: json['difficulty'] as String? ?? 'mixed',
      lastRoundScore: json['lastRoundScore'] as int?,
      lastRoundMultiplier: json['lastRoundMultiplier'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'currentRound': currentRound,
      'currentPlayerId': currentPlayerId,
      'currentTask': currentTask,
      'turnOrder': turnOrder,
      'status': status,
      'usedTaskIds': usedTaskIds,
      'difficulty': difficulty,
      if (spinningTarget != null) 'spinningTarget': spinningTarget,
      if (lastRoundScore != null) 'lastRoundScore': lastRoundScore,
      if (lastRoundMultiplier != null) 'lastRoundMultiplier': lastRoundMultiplier,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  GameEntity toEntity() {
    TaskEntity? task;
    if (currentTask != null) {
      task = TaskModel.fromJson(currentTask!).toEntity();
    }

    return GameEntity(
      gameId: gameId,
      roomId: roomId,
      currentRound: currentRound,
      currentPlayerId: currentPlayerId,
      currentTask: task,
      turnOrder: turnOrder,
      status: GameStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => GameStatus.playing,
      ),
      difficulty: GameDifficulty.values.firstWhere(
        (e) => e.name == difficulty,
        orElse: () => GameDifficulty.mixed,
      ),
      usedTaskIds: usedTaskIds,
      spinningTarget: spinningTarget,
      lastRoundScore: lastRoundScore,
      lastRoundMultiplier: lastRoundMultiplier,
    );
  }
}

class TaskModel {
  final String id;
  final String category;
  final String content;
  final int multiplier;

  const TaskModel({
    required this.id,
    required this.category,
    required this.content,
    this.multiplier = 1,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      content: json['content'] as String? ?? '',
      multiplier: json['multiplier'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'content': content,
      'multiplier': multiplier,
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      category: category,
      content: content,
      multiplier: multiplier,
    );
  }
}
