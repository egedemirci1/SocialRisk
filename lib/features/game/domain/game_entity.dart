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

  const GameEntity({
    required this.gameId,
    required this.roomId,
    this.currentRound = 1,
    required this.currentPlayerId,
    this.currentTask,
    required this.turnOrder,
    this.status = GameStatus.playing,
    this.passStreak = 0,
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
