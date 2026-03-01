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
