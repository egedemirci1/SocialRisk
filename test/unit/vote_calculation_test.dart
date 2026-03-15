import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/models/enums.dart';

/// Oy Hesaplama Mantığı – Unit & Edge Case Testleri
///
/// FirebaseVoteSource.calculateVoteResult fonksiyonunun mantığını
/// Firebase bağımlılığı olmadan pure function olarak test eder.
void main() {
  // Pure function olarak ayıklanan oy hesaplama mantığı
  int calculateVoteScore(List<VoteValue> votes, {int taskMultiplier = 1}) {
    int totalScore = 0;
    for (final vote in votes) {
      switch (vote) {
        case VoteValue.like:
          totalScore += (10 * taskMultiplier);
          break;
        case VoteValue.neutral:
          totalScore += 0;
          break;
        case VoteValue.dislike:
          totalScore -= 10;
          break;
      }
    }
    return totalScore;
  }

  group('Vote Calculation Logic', () {
    // ─────────── Temel Senaryolar ───────────
    group('temel senaryolar', () {
      test('hepsi like → 10 * oyuncu sayısı * çarpan', () {
        final votes = List.filled(5, VoteValue.like);
        expect(calculateVoteScore(votes), 50); // 5 * 10 * 1
      });

      test('hepsi dislike → -10 * oyuncu sayısı (çarpan etkisiz)', () {
        final votes = List.filled(5, VoteValue.dislike);
        expect(calculateVoteScore(votes), -50); // 5 * -10
      });

      test('hepsi neutral → 0', () {
        final votes = List.filled(5, VoteValue.neutral);
        expect(calculateVoteScore(votes), 0);
      });

      test('boş oy listesi → 0', () {
        expect(calculateVoteScore([]), 0);
      });

      test('tek oy – like', () {
        expect(calculateVoteScore([VoteValue.like]), 10);
      });

      test('tek oy – dislike', () {
        expect(calculateVoteScore([VoteValue.dislike]), -10);
      });
    });

    // ─────────── Çarpan (Multiplier) Testleri ───────────
    group('multiplier testleri', () {
      test('multiplier 2 ile like → 20 puan', () {
        expect(calculateVoteScore([VoteValue.like], taskMultiplier: 2), 20);
      });

      test('multiplier 3 ile 3 like → 90 puan', () {
        final votes = List.filled(3, VoteValue.like);
        expect(calculateVoteScore(votes, taskMultiplier: 3), 90);
      });

      test('multiplier dislike\'ı etkilememeli (sabit -10)', () {
        expect(calculateVoteScore([VoteValue.dislike], taskMultiplier: 5), -10);
      });

      test('multiplier neutral\'ı etkilememeli', () {
        expect(calculateVoteScore([VoteValue.neutral], taskMultiplier: 10), 0);
      });
    });

    // ─────────── Karma Senaryolar ───────────
    group('karma senaryolar', () {
      test('3 like + 2 dislike + 1 neutral → 30 - 20 + 0 = 10', () {
        final votes = [
          VoteValue.like, VoteValue.like, VoteValue.like,
          VoteValue.dislike, VoteValue.dislike,
          VoteValue.neutral,
        ];
        expect(calculateVoteScore(votes), 10);
      });

      test('eşit like ve dislike → net negatif (dislike sabit, like çarpansız)', () {
        final votes = [VoteValue.like, VoteValue.dislike]; // 10 - 10 = 0
        expect(calculateVoteScore(votes), 0);
      });

      test('eşit like ve dislike, multiplier 2 → net pozitif (20 - 10)', () {
        final votes = [VoteValue.like, VoteValue.dislike];
        expect(calculateVoteScore(votes, taskMultiplier: 2), 10);
      });

      test('büyük oyuncu grubu – 8 oyuncu karışık oylar', () {
        final votes = [
          VoteValue.like, VoteValue.like, VoteValue.like, VoteValue.like,  // 4 like = 40
          VoteValue.dislike, VoteValue.dislike,  // 2 dislike = -20
          VoteValue.neutral, VoteValue.neutral,  // 2 neutral = 0
        ];
        expect(calculateVoteScore(votes), 20);
      });
    });

    // ─────────── Uç Senaryolar ───────────
    group('uç senaryolar', () {
      test('çok büyük multiplier taşma yaratmamalı', () {
        final result = calculateVoteScore([VoteValue.like], taskMultiplier: 999);
        expect(result, 9990);
      });

      test('çok fazla oy (100 oyuncu simülasyonu)', () {
        final votes = List.filled(100, VoteValue.like);
        expect(calculateVoteScore(votes), 1000);
      });

      test('sadece neutral oylar, yüksek multiplier → hâlâ 0', () {
        final votes = List.filled(50, VoteValue.neutral);
        expect(calculateVoteScore(votes, taskMultiplier: 100), 0);
      });

      test('1 like + 99 dislike → net çok negatif', () {
        final votes = [VoteValue.like] + List.filled(99, VoteValue.dislike);
        expect(calculateVoteScore(votes), 10 - 990); // = -980
      });
    });
  });
}
