import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/models/enums.dart';

/// Oy Hesaplama Mantığı – Çoğunluk Oylaması (Majority Voting)
///
/// Kurallar:
/// - like sayısı >= dislike sayısı → pozitif: baseScore * multiplier * likes
/// - dislike sayısı > like sayısı → 0 puan
/// - neutral oylar çoğunluğa katılmaz, puan vermez
void main() {
  // Pure function — firebase_vote_source.calculateVoteResult mantığını yansıtır
  ({int totalScore, int audienceScore}) calculateVoteScore(
    List<VoteValue> votes, {
    int baseScore = 10,
    int taskMultiplier = 1,
  }) {
    int likes = 0;
    int dislikes = 0;
    for (final vote in votes) {
      switch (vote) {
        case VoteValue.like:
          likes++;
          break;
        case VoteValue.neutral:
          break;
        case VoteValue.dislike:
          dislikes++;
          break;
      }
    }
    final isPositive = likes >= dislikes;
    return (
      totalScore: isPositive ? baseScore * taskMultiplier * likes : 0,
      audienceScore: isPositive ? baseScore * likes : 0,
    );
  }

  group('Çoğunluk Oylaması (Majority Voting)', () {
    // ─────────── Temel Senaryolar ───────────
    group('temel senaryolar', () {
      test('hepsi like → baseScore * multiplier * likes', () {
        final r = calculateVoteScore(List.filled(5, VoteValue.like));
        expect(r.totalScore, 50); // 10 * 1 * 5
        expect(r.audienceScore, 50);
      });

      test('hepsi dislike → 0 (negatif çoğunluk)', () {
        final r = calculateVoteScore(List.filled(5, VoteValue.dislike));
        expect(r.totalScore, 0);
        expect(r.audienceScore, 0);
      });

      test('hepsi neutral → 0 (0 like >= 0 dislike → pozitif ama 0 like)', () {
        final r = calculateVoteScore(List.filled(5, VoteValue.neutral));
        expect(r.totalScore, 0);
        expect(r.audienceScore, 0);
      });

      test('boş oy listesi → 0', () {
        final r = calculateVoteScore([]);
        expect(r.totalScore, 0);
        expect(r.audienceScore, 0);
      });

      test('tek oy – like', () {
        final r = calculateVoteScore([VoteValue.like]);
        expect(r.totalScore, 10);
      });

      test('tek oy – dislike', () {
        final r = calculateVoteScore([VoteValue.dislike]);
        expect(r.totalScore, 0);
      });
    });

    // ─────────── Çarpan (Multiplier) Testleri ───────────
    group('multiplier testleri', () {
      test('multiplier 2 ile like → 20 puan', () {
        final r = calculateVoteScore([VoteValue.like], taskMultiplier: 2);
        expect(r.totalScore, 20);
      });

      test('multiplier 3 ile 3 like → 90 puan', () {
        final r = calculateVoteScore(
          List.filled(3, VoteValue.like),
          taskMultiplier: 3,
        );
        expect(r.totalScore, 90);
      });

      test('multiplier dislike çoğunluğunu etkilememeli → hâlâ 0', () {
        final r = calculateVoteScore([VoteValue.dislike], taskMultiplier: 5);
        expect(r.totalScore, 0);
      });

      test('multiplier neutral tek basına → 0', () {
        final r = calculateVoteScore([VoteValue.neutral], taskMultiplier: 10);
        expect(r.totalScore, 0);
      });
    });

    // ─────────── Eşitlik ve Çoğunluk ───────────
    group('eşitlik ve çoğunluk', () {
      test('1 like + 1 dislike → eşitlik → pozitif lean → 10', () {
        final r = calculateVoteScore([VoteValue.like, VoteValue.dislike]);
        expect(r.totalScore, 10); // 10 * 1 * 1 like
      });

      test('1 like + 1 dislike, mult 2 → 20', () {
        final r = calculateVoteScore(
          [VoteValue.like, VoteValue.dislike],
          taskMultiplier: 2,
        );
        expect(r.totalScore, 20);
      });

      test('2 neutral + 1 dislike → 0 (0 likes < 1 dislike)', () {
        final r = calculateVoteScore([
          VoteValue.neutral,
          VoteValue.neutral,
          VoteValue.dislike,
        ]);
        expect(r.totalScore, 0);
      });

      test('2 neutral + 1 like → 10 (1 like >= 0 dislike)', () {
        final r = calculateVoteScore([
          VoteValue.neutral,
          VoteValue.neutral,
          VoteValue.like,
        ]);
        expect(r.totalScore, 10);
      });

      test('3 like + 2 dislike → pozitif çoğunluk → 30', () {
        final r = calculateVoteScore([
          VoteValue.like, VoteValue.like, VoteValue.like,
          VoteValue.dislike, VoteValue.dislike,
        ]);
        expect(r.totalScore, 30); // 10 * 1 * 3
      });

      test('2 like + 3 dislike → negatif çoğunluk → 0', () {
        final r = calculateVoteScore([
          VoteValue.like, VoteValue.like,
          VoteValue.dislike, VoteValue.dislike, VoteValue.dislike,
        ]);
        expect(r.totalScore, 0);
      });
    });

    // ─────────── Büyük Grup Testleri ───────────
    group('büyük grup', () {
      test('8 oyuncu karışık: 4 like + 2 dislike + 2 neutral → 40', () {
        final r = calculateVoteScore([
          VoteValue.like, VoteValue.like, VoteValue.like, VoteValue.like,
          VoteValue.dislike, VoteValue.dislike,
          VoteValue.neutral, VoteValue.neutral,
        ]);
        // 4 >= 2 → pozitif → 10 * 1 * 4 = 40
        expect(r.totalScore, 40);
        expect(r.audienceScore, 40);
      });

      test('1 like + 99 dislike → 0', () {
        final votes = [VoteValue.like] + List.filled(99, VoteValue.dislike);
        final r = calculateVoteScore(votes);
        expect(r.totalScore, 0);
      });

      test('çok fazla oy (100 like)', () {
        final r = calculateVoteScore(List.filled(100, VoteValue.like));
        expect(r.totalScore, 1000);
      });
    });

    // ─────────── Economy baseScore testi ───────────
    group('economy baseScore', () {
      test('economy baseScore 15 ile 2 like mult 2 → 60', () {
        final r = calculateVoteScore(
          [VoteValue.like, VoteValue.like],
          baseScore: 15,
          taskMultiplier: 2,
        );
        expect(r.totalScore, 60); // 15 * 2 * 2
        expect(r.audienceScore, 30); // 15 * 2
      });
    });
  });
}
