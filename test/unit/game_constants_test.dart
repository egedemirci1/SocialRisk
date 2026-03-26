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

      test('Tüm kategorilerin başlangıç çarpanı 10 olmalı', () {
        final market = GameConstants.defaultMarketValues;
        for (final entry in market.entries) {
          expect(entry.value, 10,
              reason: '${entry.key} kategorisi 10 olmalı');
        }
      });

      test('Ekonomi modu puan sınırları (min 0, max 10) doğru tanımlanmalı', () {
        expect(GameConstants.minMarketValue, 0);
        expect(GameConstants.maxMarketValue, 10);
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

      test('marketDecayAmount 2 olmalı', () {
        expect(GameConstants.marketDecayAmount, 2);
      });

      test('çok kategorili oyunda hot deal kategori 12 baz puan olur', () {
        final values = GameConstants.buildEconomyTurnValues(
          categories: const ['Bilgi', 'Görsel', 'Mahrem'],
          hotCategory: 'Bilgi',
        );

        expect(values['Bilgi'], 12);
        expect(values['Görsel'], 10);
        expect(values['Mahrem'], 10);
      });

      test('tek kategorili oyunda hot deal uygulanmaz ve baz 10 kalır', () {
        final values = GameConstants.buildEconomyTurnValues(
          categories: const ['Bilgi'],
          hotCategory: 'Bilgi',
          penalizedCategory: 'Bilgi',
        );

        expect(values['Bilgi'], 10);
      });

      test('iki kategorili oyunda hot deal uygulanmaz ve tüm baz puanlar 10 kalır', () {
        final values = GameConstants.buildEconomyTurnValues(
          categories: const ['Bilgi', 'Görsel'],
          hotCategory: 'Bilgi',
          penalizedCategory: 'Görsel',
        );

        expect(values['Bilgi'], 10);
        expect(values['Görsel'], 10);
      });

      test('iki kategorili oyunda hot category ve penalty category üretilmez', () {
        final hotCategory = GameConstants.pickEconomyHotCategory(
          categories: const ['Bilgi', 'Görsel'],
        );
        final penalty = GameConstants.economyPenaltyCategoryForNextTurn(
          categoryCount: 2,
          selectedCategory: 'Bilgi',
          currentHotCategory: null,
        );

        expect(hotCategory, isNull);
        expect(penalty, isNull);
      });

      test('iki kategorili oyunda stored value 9 olsa bile efektif baz puan 10 çözülür', () {
        final baseBilgi = GameConstants.economyResolvedStoredBaseValue(
          category: 'Bilgi',
          storedValues: const {'Bilgi': 9, 'Görsel': 10},
        );
        final baseGorsel = GameConstants.economyResolvedStoredBaseValue(
          category: 'Görsel',
          storedValues: const {'Bilgi': 9, 'Görsel': 10},
        );

        expect(baseBilgi, 10);
        expect(baseGorsel, 10);
      });

      test('normal kategori seçilirse sonraki turda yalnızca o kategori 8 olur', () {
        final penalty = GameConstants.economyPenaltyCategoryForNextTurn(
          categoryCount: 3,
          selectedCategory: 'Görsel',
          currentHotCategory: 'Bilgi',
        );

        final values = GameConstants.buildEconomyTurnValues(
          categories: const ['Bilgi', 'Görsel', 'Mahrem'],
          hotCategory: 'Mahrem',
          penalizedCategory: penalty,
        );

        expect(penalty, 'Görsel');
        expect(values['Bilgi'], 10);
        expect(values['Görsel'], 8);
        expect(values['Mahrem'], 12);
      });

      test('oyuncu hot deal kategorisini seçerse sonraki turda ceza uygulanmaz', () {
        final penalty = GameConstants.economyPenaltyCategoryForNextTurn(
          categoryCount: 3,
          selectedCategory: 'Bilgi',
          currentHotCategory: 'Bilgi',
        );

        final values = GameConstants.buildEconomyTurnValues(
          categories: const ['Bilgi', 'Görsel', 'Mahrem'],
          hotCategory: 'Görsel',
          penalizedCategory: penalty,
        );

        expect(penalty, isNull);
        expect(values['Bilgi'], 10);
        expect(values['Görsel'], 12);
        expect(values['Mahrem'], 10);
      });

      test('hot deal seçimi ceza alan kategoriyle çakışmaz', () {
        final hotCategory = GameConstants.pickEconomyHotCategory(
          categories: const ['Bilgi', 'Görsel', 'Mahrem'],
          excludedCategories: const ['Görsel'],
        );

        expect(hotCategory, isNot('Görsel'));
        expect(const ['Bilgi', 'Mahrem'], contains(hotCategory));
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
