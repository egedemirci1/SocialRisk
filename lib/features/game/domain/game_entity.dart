import '../../../shared/models/enums.dart';

class GameEntity {
  final String gameId;
  final String roomId;
  final int currentRound;
  final String currentPlayerId;
  final TaskEntity? currentTask;
  final List<String> turnOrder;
  final GameStatus status;
  final int passStreak;
  final List<String> usedTaskIds;
  final String? spinningTarget;
  final GameDifficulty difficulty;
  final int? lastRoundScore;
  final int? lastRoundMultiplier;
  // Faz 10: Ekonomi modu alanları
  final GameMode mode;
  final Map<String, int> categoryMarketValues;
  final List<String> lockedCategories;
  final List<String> categoryPickOrder;
  final int currentPickIndex;

  const GameEntity({
    required this.gameId,
    required this.roomId,
    this.currentRound = 1,
    required this.currentPlayerId,
    this.currentTask,
    required this.turnOrder,
    this.status = GameStatus.playing,
    this.passStreak = 0,
    this.usedTaskIds = const [],
    this.spinningTarget,
    this.difficulty = GameDifficulty.mixed,
    this.lastRoundScore,
    this.lastRoundMultiplier,
    this.mode = GameMode.classic,
    this.categoryMarketValues = const {},
    this.lockedCategories = const [],
    this.categoryPickOrder = const [],
    this.currentPickIndex = 0,
  });
}

class TaskEntity {
  final String id;
  final String category;
  final String content;
  final int multiplier;

  const TaskEntity({
    required this.id,
    required this.category,
    required this.content,
    this.multiplier = 1,
  });
}
