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
  final int? lastRoundAudienceScore;
  final int? lastRoundMultiplier;
  final String? lastRoundPlayerId;
  final String? lastRoundMood;
  // Tur içi zorluk seçimi
  final String? selectedCategory;
  final String? selectedDifficulty;
  // Faz 10: Ekonomi modu
  final String mode;
  final Map<String, int> categoryMarketValues;
  final Map<String, int> categoryPickCounts;
  final List<String> lockedCategories;
  final List<String> categoryPickOrder;
  final int currentPickIndex;
  /// Borsa modunda bu tur için sıcak fırsat (12 puan) seçilmiş kategori.
  final String? hotCategory;
  /// Oyun bittiğinde sıralamaya göre oyuncu başına ödül (uid -> puan).
  final Map<String, int> rewards;
  // Görev ön-yükleme havuzu: key = "category_difficulty", value = list of task maps
  final Map<String, List<Map<String, dynamic>>> taskPool;

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
    this.lastRoundAudienceScore,
    this.lastRoundMultiplier,
    this.lastRoundPlayerId,
    this.lastRoundMood,
    this.selectedCategory,
    this.selectedDifficulty,
    this.mode = 'classic',
    this.categoryMarketValues = const {},
    this.categoryPickCounts = const {},
    this.lockedCategories = const [],
    this.categoryPickOrder = const [],
    this.currentPickIndex = 0,
    this.hotCategory,
    this.rewards = const {},
    this.taskPool = const {},
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
      lastRoundAudienceScore: json['lastRoundAudienceScore'] as int?,
      lastRoundMultiplier: json['lastRoundMultiplier'] as int?,
      lastRoundPlayerId: json['lastRoundPlayerId'] as String?,
      lastRoundMood: json['lastRoundMood'] as String?,
      selectedCategory: json['selectedCategory'] as String?,
      selectedDifficulty: json['selectedDifficulty'] as String?,
      mode: json['mode'] as String? ?? 'classic',
      categoryMarketValues: Map<String, int>.from(
        json['categoryMarketValues'] ?? {},
      ),
      categoryPickCounts: Map<String, int>.from(
        json['categoryPickCounts'] ?? {},
      ),
      lockedCategories: List<String>.from(json['lockedCategories'] ?? []),
      categoryPickOrder: List<String>.from(json['categoryPickOrder'] ?? []),
      currentPickIndex: json['currentPickIndex'] as int? ?? 0,
      hotCategory: json['hotCategory'] as String?,
      rewards: _parseRewardsMap(json['rewards']),
      taskPool: _parseTaskPool(json['taskPool']),
    );
  }

  static Map<String, int> _parseRewardsMap(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final map = <String, int>{};
    for (final e in raw.entries) {
      final k = e.key.toString();
      final v = e.value;
      if (v is int) {
        map[k] = v;
      } else if (v is num) {
        map[k] = v.toInt();
      }
    }
    return map;
  }

  /// taskPool alanını Firestore'dan güvenle parse eder
  static Map<String, List<Map<String, dynamic>>> _parseTaskPool(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final result = <String, List<Map<String, dynamic>>>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      if (entry.value is List) {
        result[key] = (entry.value as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return result;
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
      if (lastRoundAudienceScore != null)
        'lastRoundAudienceScore': lastRoundAudienceScore,
      if (lastRoundMultiplier != null)
        'lastRoundMultiplier': lastRoundMultiplier,
      if (lastRoundPlayerId != null) 'lastRoundPlayerId': lastRoundPlayerId,
      if (lastRoundMood != null) 'lastRoundMood': lastRoundMood,
      if (selectedCategory != null) 'selectedCategory': selectedCategory,
      if (selectedDifficulty != null) 'selectedDifficulty': selectedDifficulty,
      'categoryMarketValues': categoryMarketValues,
      'categoryPickCounts': categoryPickCounts,
      'lockedCategories': lockedCategories,
      'categoryPickOrder': categoryPickOrder,
      'currentPickIndex': currentPickIndex,
      if (hotCategory != null) 'hotCategory': hotCategory,
      'taskPool': taskPool,
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
      lastRoundAudienceScore: lastRoundAudienceScore,
      lastRoundMultiplier: lastRoundMultiplier,
      lastRoundPlayerId: lastRoundPlayerId,
      lastRoundMood: lastRoundMood,
      selectedCategory: selectedCategory,
      selectedDifficulty: selectedDifficulty,
      mode: GameMode.values.firstWhere(
        (e) => e.name == mode,
        orElse: () => GameMode.classic,
      ),
      categoryMarketValues: categoryMarketValues,
      categoryPickCounts: categoryPickCounts,
      lockedCategories: lockedCategories,
      categoryPickOrder: categoryPickOrder,
      currentPickIndex: currentPickIndex,
      hotCategory: hotCategory,
      rewards: rewards,
    );
  }
}

class TaskModel {
  final String id;
  final String category;
  final String content;
  final String difficulty;
  final int multiplier;
  final String? answer;

  const TaskModel({
    required this.id,
    required this.category,
    required this.content,
    required this.difficulty,
    this.multiplier = 1,
    this.answer,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      content: json['content'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'easy',
      multiplier: json['multiplier'] as int? ?? 1,
      answer: json['answer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'content': content,
      'difficulty': difficulty,
      'multiplier': multiplier,
      if (answer != null) 'answer': answer,
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      category: category,
      content: content,
      difficulty: difficulty,
      multiplier: multiplier,
      answer: answer,
    );
  }
}
