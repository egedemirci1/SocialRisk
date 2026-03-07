import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/constants/game_constants.dart';

/// GameConstants Unit Testleri
void main() {
  group('GameConstants', () {
    // ─────────── Sabit Değerler ───────────
    group('sabit değerler', () {
      test('minPlayers en az 2 olmalı', () {
        expect(GameConstants.minPlayers, greaterThanOrEqualTo(2));
      });

      test('maxPlayers, minPlayers\'dan büyük olmalı', () {
        expect(GameConstants.maxPlayers, greaterThan(GameConstants.minPlayers));
      });

      test('maxPlayers 8 olmalı', () {
        expect(GameConstants.maxPlayers, 8);
      });

      test('defaultTargetScore pozitif olmalı', () {
        expect(GameConstants.defaultTargetScore, greaterThan(0));
      });

      test('defaultMaxRounds pozitif olmalı', () {
        expect(GameConstants.defaultMaxRounds, greaterThan(0));
      });

      test('basePenalty pozitif olmalı', () {
        expect(GameConstants.basePenalty, greaterThan(0));
      });

      test('voteDuration sıfırdan büyük olmalı', () {
        expect(GameConstants.voteDuration.inSeconds, greaterThan(0));
      });
    });

    // ─────────── Kategoriler ───────────
    group('kategoriler', () {
      test('defaultCategories boş olmamalı', () {
        expect(GameConstants.defaultCategories, isNotEmpty);
      });

      test('defaultCategories 8 kategori içermeli', () {
        expect(GameConstants.defaultCategories.length, 8);
      });

      test('defaultCategoriesConst ile defaultCategories aynı içeriğe sahip olmalı', () {
        final dynamic1 = GameConstants.defaultCategories;
        final const1 = GameConstants.defaultCategoriesConst;
        expect(dynamic1, const1);
      });

      test('defaultCategories benzersiz olmalı (tekrar olmamalı)', () {
        final cats = GameConstants.defaultCategories;
        expect(cats.toSet().length, cats.length);
      });

      test('defaultCategories Özel kategorisini içermemeli', () {
        expect(GameConstants.defaultCategories.contains('Özel'), isFalse);
      });
    });

    // ─────────── Zorluk Seviyeleri ───────────
    group('zorluk seviyeleri', () {
      test('defaultDifficulties 3 seviye içermeli', () {
        expect(GameConstants.defaultDifficulties.length, 3);
      });

      test('easy, medium, hard sırasıyla bulunmalı', () {
        expect(GameConstants.defaultDifficulties, ['easy', 'medium', 'hard']);
      });
    });

    // ─────────── Ekonomi Modu ───────────
    group('ekonomi modu', () {
      test('defaultMarketValues tüm kategorileri kapsamalı', () {
        final market = GameConstants.defaultMarketValues;
        expect(market, isNotEmpty);
        // 9 kategori (8 + Özel)
        expect(market.length, 9);
      });

      test('defaultMarketValues değerleri pozitif olmalı', () {
        final market = GameConstants.defaultMarketValues;
        for (final entry in market.entries) {
          expect(entry.value, greaterThan(0),
              reason: '${entry.key} kategorisi pozitif değere sahip olmalı');
        }
      });

      test('Bilgi kategorisinin başlangıç çarpanı 1 olmalı', () {
        final market = GameConstants.defaultMarketValues;
        expect(market['Bilgi'], 1);
      });

      test('diğer kategorilerin başlangıç çarpanı 2 olmalı', () {
        final market = GameConstants.defaultMarketValues;
        for (final entry in market.entries) {
          if (entry.key != 'Bilgi') {
            expect(entry.value, 2,
                reason: '${entry.key} kategorisi 2 olmalı');
          }
        }
      });

      test('defaultPickCounts tüm değerleri 0 olmalı', () {
        final counts = GameConstants.defaultPickCounts;
        for (final entry in counts.entries) {
          expect(entry.value, 0,
              reason: '${entry.key} başlangıçta 0 olmalı');
        }
      });

      test('lockThreshold pozitif olmalı', () {
        expect(GameConstants.lockThreshold, greaterThan(0));
      });

      test('marketDecayAmount pozitif olmalı', () {
        expect(GameConstants.marketDecayAmount, greaterThan(0));
      });
    });

    // ─────────── Sınır Değer Kontrolleri ───────────
    group('sınır değer kontrolleri', () {
      test('taskPoolSizePerCombo çok büyük olmamalı (performans)', () {
        expect(GameConstants.taskPoolSizePerCombo, lessThanOrEqualTo(50));
      });

      test('voteDuration çok uzun olmamalı (UX)', () {
        expect(GameConstants.voteDuration.inSeconds, lessThanOrEqualTo(60));
      });

      test('basePenalty makul bir aralıkta olmalı', () {
        expect(GameConstants.basePenalty, inInclusiveRange(10, 200));
      });
    });
  });
}
