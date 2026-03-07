import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/utils/helpers.dart';

/// AppHelpers – Uç Senaryo (Edge Case) Testleri
void main() {
  group('AppHelpers – Edge Cases', () {
    // ─────────── generateRoomCode ───────────
    group('generateRoomCode edge cases', () {
      test('100 kez üretilen kodların hepsi benzersiz olmalı (çakışma riski düşük)', () {
        final codes = <String>{};
        for (var i = 0; i < 100; i++) {
          codes.add(AppHelpers.generateRoomCode());
        }
        // 100 üretimde en az 95 benzersiz olmalı (rastgelelik garantisi yok ama istatistiksel beklenti)
        expect(codes.length, greaterThanOrEqualTo(95));
      });

      test('üretilen kodlarda karıştırılabilir karakterler (0, O, I, 1) bulunmamalı', () {
        // Karıştırılabilir karakterler: 0 (sıfır), O (büyük harf), I (büyük i), 1 (bir)
        // Ancak mevcut charset 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789' zaten I, O, 0, 1 içermiyor
        const forbidden = {'0', 'O', 'I', '1'};
        for (var i = 0; i < 50; i++) {
          final code = AppHelpers.generateRoomCode();
          for (final c in code.split('')) {
            expect(forbidden.contains(c), isFalse,
                reason: 'Karıştırılabilir karakter bulundu: $c ($code)');
          }
        }
      });

      test('üretilen kod asla boş string olmamalı', () {
        final code = AppHelpers.generateRoomCode();
        expect(code, isNotEmpty);
      });

      test('üretilen kod sadece büyük harf ve rakam içermeli', () {
        for (var i = 0; i < 30; i++) {
          final code = AppHelpers.generateRoomCode();
          expect(code, matches(RegExp(r'^[A-Z0-9]+$')));
        }
      });
    });

    // ─────────── calculatePenalty ───────────
    group('calculatePenalty edge cases', () {
      test('basePenalty 0, passStreak pozitifken 0 döndürmeli', () {
        expect(AppHelpers.calculatePenalty(0, 5), 0);
      });

      test('çok büyük passStreak değerinde taşma olmamalı', () {
        // Dart int sınırsız (web hariç int64) ama mantıksal bir üst sınır
        final result = AppHelpers.calculatePenalty(50, 1000);
        expect(result, 50000);
      });

      test('basePenalty ve passStreak ikisi de 0 iken 0 döndürmeli', () {
        expect(AppHelpers.calculatePenalty(0, 0), 0);
      });

      test('negatif basePenalty, pozitif passStreak ile negatif sonuç döndürmeli', () {
        // Negatif basePenalty edge case (pratikte olmaz ama fonksiyon onu engellemez)
        expect(AppHelpers.calculatePenalty(-10, 2), -20);
      });

      test('passStreak tam olarak -1 iken (sınır değeri) 0 döndürmeli', () {
        expect(AppHelpers.calculatePenalty(50, -1), 0);
      });

      test('passStreak 1 iken basePenalty ile aynı değeri döndürmeli', () {
        expect(AppHelpers.calculatePenalty(100, 1), 100);
      });
    });

    // ─────────── formatTimestamp ───────────
    group('formatTimestamp edge cases', () {
      test('gece yarısı (00:00) doğru formatlanmalı', () {
        expect(AppHelpers.formatTimestamp(DateTime(2024, 1, 1, 0, 0)), '00:00');
      });

      test('günün son dakikası (23:59) doğru formatlanmalı', () {
        expect(AppHelpers.formatTimestamp(DateTime(2024, 12, 31, 23, 59)), '23:59');
      });

      test('öğle vakti (12:00) doğru formatlanmalı', () {
        expect(AppHelpers.formatTimestamp(DateTime(2024, 6, 15, 12, 0)), '12:00');
      });

      test('tek haneli saat çift haneli dakika (5:30) doğru formatlanmalı', () {
        expect(AppHelpers.formatTimestamp(DateTime(2024, 1, 1, 5, 30)), '05:30');
      });

      test('farklı tarihler aynı saati farklı etkilememeli', () {
        final t1 = AppHelpers.formatTimestamp(DateTime(2020, 1, 1, 14, 25));
        final t2 = AppHelpers.formatTimestamp(DateTime(2030, 12, 31, 14, 25));
        expect(t1, t2);
      });
    });
  });
}
