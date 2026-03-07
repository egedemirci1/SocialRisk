import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/models/enums.dart';

/// Enum Testleri – Tüm enum değerlerinin tutarlılığını doğrular
void main() {
  group('Enums', () {
    group('GameMode', () {
      test('4 mod tanımlı olmalı', () {
        expect(GameMode.values.length, 4);
      });

      test('classic ve economy aktif kullanımda olmalı', () {
        expect(GameMode.values.contains(GameMode.classic), isTrue);
        expect(GameMode.values.contains(GameMode.economy), isTrue);
      });

      test('name → enum round-trip tutarlı olmalı', () {
        for (final mode in GameMode.values) {
          final back = GameMode.values.firstWhere((e) => e.name == mode.name);
          expect(back, mode);
        }
      });
    });

    group('GameDifficulty', () {
      test('4 seviye tanımlı olmalı (easy, medium, hard, mixed)', () {
        expect(GameDifficulty.values.length, 4);
      });

      test('mixed seviyesi var olmalı (varsayılan)', () {
        expect(GameDifficulty.values.contains(GameDifficulty.mixed), isTrue);
      });
    });

    group('GameStatus', () {
      test('7 durum tanımlı olmalı', () {
        expect(GameStatus.values.length, 7);
      });

      test('temel oyun akışı durumları mevcut olmalı', () {
        final statuses = GameStatus.values.map((e) => e.name).toSet();
        expect(statuses.contains('waiting'), isTrue);
        expect(statuses.contains('playing'), isTrue);
        expect(statuses.contains('voting'), isTrue);
        expect(statuses.contains('performing'), isTrue);
        expect(statuses.contains('results'), isTrue);
        expect(statuses.contains('finished'), isTrue);
        expect(statuses.contains('choosingDifficulty'), isTrue);
      });
    });

    group('VoteValue', () {
      test('3 değer tanımlı olmalı', () {
        expect(VoteValue.values.length, 3);
      });

      test('like, neutral, dislike mevcut olmalı', () {
        expect(VoteValue.values.contains(VoteValue.like), isTrue);
        expect(VoteValue.values.contains(VoteValue.neutral), isTrue);
        expect(VoteValue.values.contains(VoteValue.dislike), isTrue);
      });
    });

    group('EndConditionType', () {
      test('2 koşul tipi tanımlı olmalı', () {
        expect(EndConditionType.values.length, 2);
      });

      test('score ve rounds mevcut olmalı', () {
        expect(EndConditionType.values.contains(EndConditionType.score), isTrue);
        expect(EndConditionType.values.contains(EndConditionType.rounds), isTrue);
      });
    });

    group('RoomVisibility', () {
      test('2 görünürlük tanımlı olmalı', () {
        expect(RoomVisibility.values.length, 2);
      });
    });

    group('TaskType', () {
      test('3 görev tipi tanımlı olmalı', () {
        expect(TaskType.values.length, 3);
      });
    });

    group('tüm enumlar için name benzersizliği', () {
      void checkUniqueNames<T extends Enum>(List<T> values, String enumName) {
        final names = values.map((e) => e.name).toSet();
        expect(names.length, values.length,
            reason: '$enumName enum değerleri benzersiz isimlere sahip olmalı');
      }

      test('GameMode name\'leri benzersiz', () => checkUniqueNames(GameMode.values, 'GameMode'));
      test('GameDifficulty name\'leri benzersiz', () => checkUniqueNames(GameDifficulty.values, 'GameDifficulty'));
      test('GameStatus name\'leri benzersiz', () => checkUniqueNames(GameStatus.values, 'GameStatus'));
      test('VoteValue name\'leri benzersiz', () => checkUniqueNames(VoteValue.values, 'VoteValue'));
      test('EndConditionType name\'leri benzersiz', () => checkUniqueNames(EndConditionType.values, 'EndConditionType'));
      test('RoomVisibility name\'leri benzersiz', () => checkUniqueNames(RoomVisibility.values, 'RoomVisibility'));
      test('TaskType name\'leri benzersiz', () => checkUniqueNames(TaskType.values, 'TaskType'));
    });
  });
}
