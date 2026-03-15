import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/utils/helpers.dart';

void main() {
  group('AppHelpers', () {
    group('generateRoomCode', () {
      test('6 karakter döndürmeli', () {
        final code = AppHelpers.generateRoomCode();
        expect(code.length, 6);
      });

      test('sadece izin verilen karakter setini kullanmalı', () {
        const allowed = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        for (var i = 0; i < 20; i++) {
          final code = AppHelpers.generateRoomCode();
          for (final c in code.split('')) {
            expect(allowed.contains(c), isTrue);
          }
        }
      });
    });

    group('calculatePenalty', () {
      test('passStreak 0 iken 0 döndürmeli', () {
        expect(AppHelpers.calculatePenalty(50, 0), 0);
      });

      test('passStreak negatif iken 0 döndürmeli', () {
        expect(AppHelpers.calculatePenalty(50, -1), 0);
      });

      test('passStreak 1 iken basePenalty döndürmeli', () {
        expect(AppHelpers.calculatePenalty(50, 1), 50);
      });

      test('passStreak 3 iken basePenalty * 3 döndürmeli', () {
        expect(AppHelpers.calculatePenalty(50, 3), 150);
      });

      test('farklı basePenalty değerleriyle doğru hesaplamalı', () {
        expect(AppHelpers.calculatePenalty(100, 2), 200);
        expect(AppHelpers.calculatePenalty(25, 4), 100);
      });
    });

    group('formatTimestamp', () {
      test('saat ve dakika HH:mm formatında olmalı', () {
        expect(
          AppHelpers.formatTimestamp(DateTime(2024, 1, 1, 9, 5)),
          '09:05',
        );
      });

      test('tek haneli saat ve dakikada başına 0 eklenmeli', () {
        expect(
          AppHelpers.formatTimestamp(DateTime(2024, 1, 1, 0, 0)),
          '00:00',
        );
        expect(
          AppHelpers.formatTimestamp(DateTime(2024, 1, 1, 3, 7)),
          '03:07',
        );
      });

      test('çift haneli saat ve dakikada olduğu gibi kalmalı', () {
        expect(
          AppHelpers.formatTimestamp(DateTime(2024, 1, 1, 14, 35)),
          '14:35',
        );
        expect(
          AppHelpers.formatTimestamp(DateTime(2024, 1, 1, 23, 59)),
          '23:59',
        );
      });
    });
  });
}
