import 'dart:async';

import 'package:social_risk/core/constants/game_constants.dart';
import 'package:social_risk/features/game/domain/game_entity.dart';
import 'package:social_risk/features/game/domain/game_repository.dart';
import 'package:social_risk/shared/models/enums.dart';

/// Test için GameRepository — bellek içi oyun durumu ve stream'ler.
/// watchGame ile abone olunan oyunlar güncellemeleri alır; endGame ile stream kapatılır.
class FakeGameRepository implements GameRepository {
  FakeGameRepository({Map<String, GameEntity>? initialGames}) {
    if (initialGames != null) {
      for (final e in initialGames.entries) {
        _state[e.key] = _MutableGameState.fromEntity(e.value);
        _emit(e.key);
      }
    }
  }

  final Map<String, _MutableGameState> _state = {};
  final Map<String, StreamController<GameEntity?>> _controllers = {};
  final Map<String, int> _playerScores = {}; // key: '$roomId/$playerId'

  String _scoreKey(String roomId, String playerId) => '$roomId/$playerId';

  int getPlayerScore(String roomId, String playerId) =>
      _playerScores[_scoreKey(roomId, playerId)] ?? 0;

  GameEntity? getGame(String gameId) => _state[gameId]?.toEntity();

  /// endGame sonrası ilgili oyunun stream controller'ının kapatıldığını doğrulamak için.
  bool isStreamClosed(String gameId) =>
      _controllers[gameId]?.isClosed ?? true;

  Stream<GameEntity?> watchGame(String gameId) {
    _controllers[gameId] ??= StreamController<GameEntity?>.broadcast();
    final state = _state[gameId];
    if (state != null) {
      _controllers[gameId]!.add(state.toEntity());
    }
    return _controllers[gameId]!.stream;
  }

  void _emit(String gameId) {
    final c = _controllers[gameId];
    final s = _state[gameId];
    if (c != null && !c.isClosed && s != null) {
      c.add(s.toEntity());
    }
  }

  _MutableGameState _getOrCreate(String gameId, {required String roomId}) {
    if (!_state.containsKey(gameId)) {
      _state[gameId] = _MutableGameState(
        gameId: gameId,
        roomId: roomId,
        currentPlayerId: '',
        turnOrder: [],
      );
    }
    return _state[gameId]!;
  }

  @override
  Future<void> setSpinningTarget({
    required String gameId,
    required String? target,
  }) async {
    final s = _state[gameId];
    if (s == null) return;
    s.spinningTarget = target;
    _emit(gameId);
  }

  @override
  Future<void> setCurrentTask({
    required String gameId,
    required TaskEntity task,
  }) async {
    final s = _state[gameId];
    if (s == null) return;
    s.currentTask = task;
    s.usedTaskIds = [...s.usedTaskIds, task.id];
    s.spinningTarget = null;
    _emit(gameId);
  }

  @override
  Future<void> assignTaskByCategory({
    required String gameId,
    required String category,
  }) async {
    final s = _state[gameId];
    if (s == null) return;
    s.selectedCategory = category;
    s.status = GameStatus.choosingDifficulty;
    s.spinningTarget = null;
    _emit(gameId);
  }

  @override
  Future<void> chooseDifficulty({
    required String gameId,
    required String difficulty,
  }) async {
    final s = _state[gameId];
    if (s == null) return;
    final task = s.pendingTask ?? const TaskEntity(
      id: 'task-1',
      category: 'Fiziksel',
      content: 'Test',
      difficulty: 'medium',
      multiplier: 2,
    );
    s.currentTask = task;
    s.usedTaskIds = [...s.usedTaskIds, task.id];
    s.selectedDifficulty = difficulty;
    s.status = GameStatus.playing;
    s.pendingTask = null;
    _emit(gameId);
  }

  /// Testte kullanılmak üzere: chooseDifficulty öncesi atanacak görev.
  void setPendingTask(String gameId, TaskEntity task) {
    final s = _state[gameId];
    if (s != null) {
      s.pendingTask = task;
    }
  }

  @override
  Future<void> acceptTask(String gameId) async {
    final s = _state[gameId];
    if (s == null) return;
    s.status = GameStatus.performing;
    _emit(gameId);
  }

  @override
  Future<void> proceedToVoting(String gameId) async {
    final s = _state[gameId];
    if (s == null) return;
    s.status = GameStatus.voting;
    _emit(gameId);
  }

  @override
  Future<void> passTask({
    required String gameId,
    required String roomId,
    required String playerId,
    required int basePenalty,
  }) async {
    final s = _state[gameId];
    if (s == null) return;
    final key = _scoreKey(roomId, playerId);
    final current = _playerScores[key] ?? 0;
    final penalty = basePenalty; // basit: streak yok
    _playerScores[key] = current - penalty;
    s.status = GameStatus.results;
    s.lastRoundScore = -penalty;
    s.lastRoundMultiplier = 0;
    s.lastRoundPlayerId = playerId;
    _emit(gameId);
  }

  @override
  Future<void> setRoundResult({
    required String gameId,
    required int score,
    required int multiplier,
  }) async {
    final s = _state[gameId];
    if (s == null) return;
    s.status = GameStatus.results;
    s.lastRoundScore = score;
    s.lastRoundMultiplier = multiplier;
    s.lastRoundPlayerId = s.currentPlayerId;
    _emit(gameId);
  }

  @override
  Future<void> nextTurn(String gameId) async {
    final s = _state[gameId];
    if (s == null || s.turnOrder.isEmpty) return;
    final idx = s.turnOrder.indexOf(s.currentPlayerId);
    if (idx < 0) return;
    final nextIdx = (idx + 1) % s.turnOrder.length;
    final isNewRound = nextIdx == 0;
    s.currentPlayerId = s.turnOrder[nextIdx];
    s.currentTask = null;
    s.selectedCategory = null;
    s.selectedDifficulty = null;
    s.status = GameStatus.playing;
    s.spinningTarget = null;
    if (isNewRound) {
      s.currentRound++;
    }
    _emit(gameId);
  }

  @override
  Future<void> nextRound(String gameId) async {
    final s = _state[gameId];
    if (s == null) return;
    s.currentRound++;
    s.currentPlayerId = s.turnOrder.isNotEmpty ? s.turnOrder.first : s.currentPlayerId;
    s.currentTask = null;
    s.selectedCategory = null;
    s.selectedDifficulty = null;
    s.spinningTarget = null;
    _emit(gameId);
  }

  @override
  Future<void> updatePlayerScore({
    required String roomId,
    required String playerId,
    required int scoreToAdd,
  }) async {
    final key = _scoreKey(roomId, playerId);
    _playerScores[key] = (_playerScores[key] ?? 0) + scoreToAdd;
  }

  @override
  Future<void> endGame(String gameId) async {
    final s = _state[gameId];
    if (s != null) {
      s.status = GameStatus.finished;
      _emit(gameId);
    }
    final c = _controllers[gameId];
    if (c != null && !c.isClosed) {
      await c.close();
    }
  }

  @override
  Future<bool> checkScoreEndCondition({
    required String roomId,
    required int targetScore,
  }) async {
    for (final e in _playerScores.entries) {
      if (e.key.startsWith('$roomId/') && e.value >= targetScore) return true;
    }
    return false;
  }

  @override
  Future<void> initEconomyRound({
    required String gameId,
    required String roomId,
  }) async {
    final s = _state[gameId];
    if (s == null) return;
    final pickOrder = s.turnOrder.isNotEmpty ? List<String>.from(s.turnOrder) : [s.currentPlayerId];
    s.categoryPickOrder = pickOrder;
    s.currentPickIndex = 0;
    s.lockedCategories = [];
    s.categoryMarketValues = Map.from(GameConstants.defaultMarketValues);
    s.currentTask = null;
    s.selectedCategory = null;
    s.selectedDifficulty = null;
    s.spinningTarget = null;
    s.currentPlayerId = pickOrder.isNotEmpty ? pickOrder.first : s.currentPlayerId;
    s.status = GameStatus.playing;
    s.mode = GameMode.economy;
    _emit(gameId);
  }

  @override
  Future<void> pickCategoryEconomy({
    required String gameId,
    required String playerId,
    required String category,
  }) async {
    final s = _state[gameId];
    if (s == null) throw Exception('Oyun bulunamadı!');
    if (s.lockedCategories.contains(category)) throw Exception('Bu kategori kilitli!');
    final updatedMarket = Map<String, int>.from(s.categoryMarketValues);
    final currentValue = updatedMarket[category] ?? 1;
    final newValue = (currentValue - GameConstants.marketDecayAmount).clamp(1, 10);
    updatedMarket[category] = newValue;
    s.categoryMarketValues = updatedMarket;
    final defaultVal = GameConstants.defaultMarketValues[category] ?? 1;
    final timesSelected = defaultVal - newValue + 1;
    if (timesSelected >= GameConstants.lockThreshold) {
      s.lockedCategories = [...s.lockedCategories, category];
    }
    s.currentPickIndex++;
    final allPicked = s.currentPickIndex >= s.categoryPickOrder.length;
    s.currentPlayerId = allPicked
        ? (s.categoryPickOrder.isNotEmpty ? s.categoryPickOrder.first : s.currentPlayerId)
        : s.categoryPickOrder[s.currentPickIndex];
    s.selectedCategory = category;
    s.status = GameStatus.choosingDifficulty;
    s.spinningTarget = null;
    _emit(gameId);
  }
}

class _MutableGameState {
  _MutableGameState({
    required this.gameId,
    required this.roomId,
    required this.currentPlayerId,
    required this.turnOrder,
    this.currentRound = 1,
    this.currentTask,
    this.status = GameStatus.playing,
    this.passStreak = 0,
    List<String>? usedTaskIds,
    this.spinningTarget,
    this.difficulty = GameDifficulty.mixed,
    this.lastRoundScore,
    this.lastRoundMultiplier,
    this.lastRoundPlayerId,
    this.selectedCategory,
    this.selectedDifficulty,
    this.mode = GameMode.classic,
    Map<String, int>? categoryMarketValues,
    List<String>? lockedCategories,
    List<String>? categoryPickOrder,
    this.currentPickIndex = 0,
  })  : usedTaskIds = usedTaskIds ?? [],
        categoryMarketValues = categoryMarketValues ?? {},
        lockedCategories = lockedCategories ?? [],
        categoryPickOrder = categoryPickOrder ?? [];

  final String gameId;
  final String roomId;
  int currentRound;
  String currentPlayerId;
  TaskEntity? currentTask;
  List<String> turnOrder;
  GameStatus status;
  int passStreak;
  List<String> usedTaskIds;
  String? spinningTarget;
  GameDifficulty difficulty;
  int? lastRoundScore;
  int? lastRoundMultiplier;
  String? lastRoundPlayerId;
  String? selectedCategory;
  String? selectedDifficulty;
  GameMode mode;
  Map<String, int> categoryMarketValues;
  List<String> lockedCategories;
  List<String> categoryPickOrder;
  int currentPickIndex;

  TaskEntity? pendingTask;

  factory _MutableGameState.fromEntity(GameEntity e) {
    return _MutableGameState(
      gameId: e.gameId,
      roomId: e.roomId,
      currentRound: e.currentRound,
      currentPlayerId: e.currentPlayerId,
      turnOrder: List.from(e.turnOrder),
      currentTask: e.currentTask,
      status: e.status,
      passStreak: e.passStreak,
      usedTaskIds: List.from(e.usedTaskIds),
      spinningTarget: e.spinningTarget,
      difficulty: e.difficulty,
      lastRoundScore: e.lastRoundScore,
      lastRoundMultiplier: e.lastRoundMultiplier,
      lastRoundPlayerId: e.lastRoundPlayerId,
      selectedCategory: e.selectedCategory,
      selectedDifficulty: e.selectedDifficulty,
      mode: e.mode,
      categoryMarketValues: Map.from(e.categoryMarketValues),
      lockedCategories: List.from(e.lockedCategories),
      categoryPickOrder: List.from(e.categoryPickOrder),
      currentPickIndex: e.currentPickIndex,
    );
  }

  GameEntity toEntity() {
    return GameEntity(
      gameId: gameId,
      roomId: roomId,
      currentRound: currentRound,
      currentPlayerId: currentPlayerId,
      turnOrder: turnOrder,
      currentTask: currentTask,
      status: status,
      passStreak: passStreak,
      usedTaskIds: usedTaskIds,
      spinningTarget: spinningTarget,
      difficulty: difficulty,
      lastRoundScore: lastRoundScore,
      lastRoundMultiplier: lastRoundMultiplier,
      lastRoundPlayerId: lastRoundPlayerId,
      selectedCategory: selectedCategory,
      selectedDifficulty: selectedDifficulty,
      mode: mode,
      categoryMarketValues: categoryMarketValues,
      lockedCategories: lockedCategories,
      categoryPickOrder: categoryPickOrder,
      currentPickIndex: currentPickIndex,
    );
  }
}
