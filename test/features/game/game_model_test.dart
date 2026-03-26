import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/game/data/game_model.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('GameModel', () {
    final fullJson = {
      'roomId': 'room123',
      'currentRound': 2,
      'currentPlayerId': 'user1',
      'currentTask': {
        'id': 'task1',
        'category': 'Fiziksel',
        'content': 'Test task',
        'difficulty': 'easy',
        'multiplier': 1,
      },
      'turnOrder': ['user1', 'user2'],
      'status': 'playing',
      'usedTaskIds': ['task0'],
      'difficulty': 'mixed',
      'mode': 'economy',
      'spinningTarget': 'user2',
      'lastRoundScore': 50,
      'lastRoundMultiplier': 1,
      'lastRoundPlayerId': 'user2',
      'selectedCategory': 'Fiziksel',
      'selectedDifficulty': 'easy',
      'categoryMarketValues': {'Fiziksel': 2, 'Bilgi': 1},
      'categoryPickCounts': {'Fiziksel': 1},
      'lockedCategories': ['Mahrem'],
      'categoryPickOrder': ['user1', 'user2'],
      'currentPickIndex': 0,
      'taskPool': {
        'Fiziksel_easy': [
          {'id': 'tp1', 'content': 'Pool task'}
        ]
      },
    };

    test('fromJson all fields correctly', () {
      final model = GameModel.fromJson(fullJson, 'game123');

      expect(model.gameId, 'game123');
      expect(model.roomId, 'room123');
      expect(model.currentRound, 2);
      expect(model.currentPlayerId, 'user1');
      expect(model.currentTask?['id'], 'task1');
      expect(model.turnOrder, ['user1', 'user2']);
      expect(model.status, 'playing');
      expect(model.usedTaskIds, ['task0']);
      expect(model.difficulty, 'mixed');
      expect(model.mode, 'economy');
      expect(model.spinningTarget, 'user2');
      expect(model.lastRoundScore, 50);
      expect(model.lastRoundMultiplier, 1);
      expect(model.lastRoundPlayerId, 'user2');
      expect(model.selectedCategory, 'Fiziksel');
      expect(model.selectedDifficulty, 'easy');
      expect(model.categoryMarketValues['Fiziksel'], 2);
      expect(model.categoryPickCounts['Fiziksel'], 1);
      expect(model.lockedCategories, contains('Mahrem'));
      expect(model.categoryPickOrder, ['user1', 'user2']);
      expect(model.currentPickIndex, 0);
      expect(model.taskPool.containsKey('Fiziksel_easy'), true);
      expect(model.taskPool['Fiziksel_easy']?.first['id'], 'tp1');
    });

    test('toJson returns complete map', () {
      final model = GameModel.fromJson(fullJson, 'game123');
      final json = model.toJson();

      expect(json['roomId'], 'room123');
      expect(json['currentRound'], 2);
      expect(json['currentPlayerId'], 'user1');
      expect(json['status'], 'playing');
      expect(json['mode'], 'economy');
      expect(json['spinningTarget'], 'user2');
      expect(json['categoryPickCounts']['Fiziksel'], 1);
      expect(json.containsKey('createdAt'), true);
    });

    test('toEntity converts correctly', () {
      final model = GameModel.fromJson(fullJson, 'game123');
      final entity = model.toEntity();

      expect(entity.gameId, 'game123');
      expect(entity.status, GameStatus.playing);
      expect(entity.mode, GameMode.economy);
      expect(entity.currentTask?.id, 'task1');
    });

    test('_parseTaskPool handles null and invalid types', () {
      final model = GameModel.fromJson({'roomId': 'r', 'currentPlayerId': 'p', 'taskPool': null}, 'id');
      expect(model.taskPool, isEmpty);

      final model2 = GameModel.fromJson({'roomId': 'r', 'currentPlayerId': 'p', 'taskPool': 'invalid'}, 'id');
      expect(model2.taskPool, isEmpty);
    });
  });

  group('TaskModel', () {
    test('fromJson handles nulls with defaults', () {
      final model = TaskModel.fromJson({});
      expect(model.id, '');
      expect(model.difficulty, 'easy');
      expect(model.multiplier, 1);
    });

    test('toEntity converts correctly', () {
      const model = TaskModel(id: 't1', category: 'c', content: 'cnt', difficulty: 'hard', multiplier: 3);
      final entity = model.toEntity();
      expect(entity.id, 't1');
      expect(entity.multiplier, 3);
    });
  });
}
