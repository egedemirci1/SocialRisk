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
  final int? lastRoundAudienceScore;
  final int? lastRoundMultiplier;
  final String? lastRoundPlayerId;
  final String? lastRoundMood;
  // Tur içi zorluk seçimi (Risk/Ödül)
  final String? selectedCategory;
  final String? selectedDifficulty; // easy, medium, hard
  // Faz 10: Ekonomi modu alanları
  final GameMode mode;
  final Map<String, int> categoryMarketValues;
  final Map<String, int> categoryPickCounts;
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
    this.lastRoundAudienceScore,
    this.lastRoundMultiplier,
    this.lastRoundPlayerId,
    this.lastRoundMood,
    this.selectedCategory,
    this.selectedDifficulty,
    this.mode = GameMode.classic,
    this.categoryMarketValues = const {},
    this.categoryPickCounts = const {},
    this.lockedCategories = const [],
    this.categoryPickOrder = const [],
    this.currentPickIndex = 0,
  });
}

class TaskEntity {
  final String id;
  final String category;
  final String content;
  final String difficulty; // easy, medium, hard
  final int multiplier;

  const TaskEntity({
    required this.id,
    required this.category,
    required this.content,
    required this.difficulty,
    this.multiplier = 1,
  });
}
