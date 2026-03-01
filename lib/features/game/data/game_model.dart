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
  // Tur içi zorluk seçimi
  final String? selectedCategory;
  final String? selectedDifficulty;
  // Faz 10: Ekonomi modu
  final String mode;
  final Map<String, int> categoryMarketValues;
  final List<String> lockedCategories;
  final List<String> categoryPickOrder;
  final int currentPickIndex;

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
    this.selectedCategory,
    this.selectedDifficulty,
    this.mode = 'classic',
    this.categoryMarketValues = const {},
    this.lockedCategories = const [],
    this.categoryPickOrder = const [],
    this.currentPickIndex = 0,
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
      selectedCategory: json['selectedCategory'] as String?,
      selectedDifficulty: json['selectedDifficulty'] as String?,
      mode: json['mode'] as String? ?? 'classic',
      categoryMarketValues: Map<String, int>.from(json['categoryMarketValues'] ?? {}),
      lockedCategories: List<String>.from(json['lockedCategories'] ?? []),
      categoryPickOrder: List<String>.from(json['categoryPickOrder'] ?? []),
      currentPickIndex: json['currentPickIndex'] as int? ?? 0,
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
      'mode': mode,
      if (spinningTarget != null) 'spinningTarget': spinningTarget,
      if (lastRoundScore != null) 'lastRoundScore': lastRoundScore,
      if (lastRoundMultiplier != null) 'lastRoundMultiplier': lastRoundMultiplier,
      if (selectedCategory != null) 'selectedCategory': selectedCategory,
      if (selectedDifficulty != null) 'selectedDifficulty': selectedDifficulty,
      'categoryMarketValues': categoryMarketValues,
      'lockedCategories': lockedCategories,
      'categoryPickOrder': categoryPickOrder,
      'currentPickIndex': currentPickIndex,
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
      selectedCategory: selectedCategory,
      selectedDifficulty: selectedDifficulty,
      mode: GameMode.values.firstWhere(
        (e) => e.name == mode,
        orElse: () => GameMode.classic,
      ),
      categoryMarketValues: categoryMarketValues,
      lockedCategories: lockedCategories,
      categoryPickOrder: categoryPickOrder,
      currentPickIndex: currentPickIndex,
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
