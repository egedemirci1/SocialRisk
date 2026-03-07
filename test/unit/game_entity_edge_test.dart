import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/game/domain/game_entity.dart';
import 'package:social_risk/shared/models/enums.dart';

/// GameEntity & TaskEntity – Unit & Edge Case Testleri
void main() {
  group('GameEntity', () {
    // ─────────── Constructor Defaults ───────────
    group('constructor varsayılan değerler', () {
      test('minimum parametreyle oluşturulabilmeli', () {
        const game = GameEntity(
          gameId: 'game_1',
          roomId: 'room_1',
          currentPlayerId: 'player_1',
          turnOrder: ['player_1', 'player_2'],
        );

        expect(game.currentRound, 1);
        expect(game.status, GameStatus.playing);
        expect(game.passStreak, 0);
        expect(game.usedTaskIds, isEmpty);
        expect(game.currentTask, isNull);
        expect(game.spinningTarget, isNull);
        expect(game.difficulty, GameDifficulty.mixed);
        expect(game.lastRoundScore, isNull);
        expect(game.lastRoundMultiplier, isNull);
        expect(game.mode, GameMode.classic);
        expect(game.categoryMarketValues, isEmpty);
        expect(game.lockedCategories, isEmpty);
      });
    });

    // ─────────── Turn Order Testleri ───────────
    group('turnOrder mantığı', () {
      test('2 oyunculu oyunda sıra doğru belirlenmeli', () {
        const game = GameEntity(
          gameId: 'g',
          roomId: 'r',
          currentPlayerId: 'p1',
          turnOrder: ['p1', 'p2'],
        );
        expect(game.turnOrder.length, 2);
        expect(game.turnOrder.first, game.currentPlayerId);
      });

      test('8 oyunculu (max) oyunda turnOrder 8 eleman içermeli', () {
        final turnOrder = List.generate(8, (i) => 'player_$i');
        final game = GameEntity(
          gameId: 'g',
          roomId: 'r',
          currentPlayerId: 'player_0',
          turnOrder: turnOrder,
        );
        expect(game.turnOrder.length, 8);
      });

      test('boş turnOrder ile oluşturulabilmeli (validation başka katmanda)', () {
        const game = GameEntity(
          gameId: 'g',
          roomId: 'r',
          currentPlayerId: 'p1',
          turnOrder: [],
        );
        expect(game.turnOrder, isEmpty);
      });
    });

    // ─────────── Status Transitions ───────────
    group('status geçişleri', () {
      test('tüm GameStatus değerleri atanabilmeli', () {
        for (final status in GameStatus.values) {
          final game = GameEntity(
            gameId: 'g',
            roomId: 'r',
            currentPlayerId: 'p',
            turnOrder: ['p'],
            status: status,
          );
          expect(game.status, status);
        }
      });
    });

    // ─────────── Ekonomi Modu ───────────
    group('ekonomi modu alanları', () {
      test('categoryMarketValues dolu oluşturulabilmeli', () {
        final game = GameEntity(
          gameId: 'g_eco',
          roomId: 'r_eco',
          currentPlayerId: 'p',
          turnOrder: ['p'],
          mode: GameMode.economy,
          categoryMarketValues: {'Fiziksel': 2, 'Bilgi': 1, 'Dijital': 2},
        );
        expect(game.mode, GameMode.economy);
        expect(game.categoryMarketValues['Bilgi'], 1);
        expect(game.categoryMarketValues['Fiziksel'], 2);
      });

      test('lockedCategories birden fazla kategori içerebilmeli', () {
        const game = GameEntity(
          gameId: 'g',
          roomId: 'r',
          currentPlayerId: 'p',
          turnOrder: ['p'],
          lockedCategories: ['Fiziksel', 'Bilgi', 'Dijital'],
        );
        expect(game.lockedCategories.length, 3);
        expect(game.lockedCategories.contains('Fiziksel'), isTrue);
      });

      test('currentPickIndex sıfırdan başlamalı', () {
        const game = GameEntity(
          gameId: 'g',
          roomId: 'r',
          currentPlayerId: 'p',
          turnOrder: ['p'],
        );
        expect(game.currentPickIndex, 0);
      });
    });

    // ─────────── UsedTaskIds ───────────
    group('usedTaskIds', () {
      test('kullanılmış görev IDleri düzgün takip edilmeli', () {
        const game = GameEntity(
          gameId: 'g',
          roomId: 'r',
          currentPlayerId: 'p',
          turnOrder: ['p'],
          usedTaskIds: ['task_1', 'task_2', 'task_3'],
        );
        expect(game.usedTaskIds.length, 3);
        expect(game.usedTaskIds.contains('task_2'), isTrue);
      });
    });
  });

  group('TaskEntity', () {
    test('tam parametrelerle oluşturulabilmeli', () {
      const task = TaskEntity(
        id: 'task_100',
        category: 'Fiziksel',
        content: '50 şınav çek',
        difficulty: 'hard',
        multiplier: 3,
      );

      expect(task.id, 'task_100');
      expect(task.category, 'Fiziksel');
      expect(task.content, '50 şınav çek');
      expect(task.difficulty, 'hard');
      expect(task.multiplier, 3);
    });

    test('varsayılan multiplier 1 olmalı', () {
      const task = TaskEntity(
        id: 'task_d',
        category: 'Bilgi',
        content: 'Soru',
        difficulty: 'easy',
      );
      expect(task.multiplier, 1);
    });

    test('Türkçe karakter içeren content doğru saklanmalı', () {
      const task = TaskEntity(
        id: 'task_tr',
        category: 'İtiraf',
        content: 'Ğüşöç İıÜÖŞĞÇ karakterleri test',
        difficulty: 'medium',
      );
      expect(task.content, contains('Ğüşöç'));
    });

    test('boş content kabul edilmeli', () {
      const task = TaskEntity(
        id: 'task_empty',
        category: 'Zihinsel',
        content: '',
        difficulty: 'easy',
      );
      expect(task.content, isEmpty);
    });

    test('tüm zorluk seviyeleri kabul edilmeli', () {
      for (final diff in ['easy', 'medium', 'hard']) {
        final task = TaskEntity(
          id: 'task_$diff',
          category: 'Test',
          content: 'Test content',
          difficulty: diff,
        );
        expect(task.difficulty, diff);
      }
    });
  });
}
