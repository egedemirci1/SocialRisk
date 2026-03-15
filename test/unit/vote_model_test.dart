import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/voting/data/vote_model.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('VoteModel', () {
    test('fromJson like değeri doğru parse edilmeli', () {
      final model = VoteModel.fromJson({'value': 'like'}, 'voter_1');
      expect(model.voterId, 'voter_1');
      expect(model.value, VoteValue.like);
    });

    test('fromJson neutral değeri doğru parse edilmeli', () {
      final model = VoteModel.fromJson({'value': 'neutral'}, 'v2');
      expect(model.value, VoteValue.neutral);
    });

    test('fromJson dislike değeri doğru parse edilmeli', () {
      final model = VoteModel.fromJson({'value': 'dislike'}, 'v3');
      expect(model.value, VoteValue.dislike);
    });

    test('fromJson bilinmeyen value varsa neutral varsayılmalı', () {
      final model = VoteModel.fromJson({'value': 'invalid'}, 'v4');
      expect(model.value, VoteValue.neutral);
    });

    test('fromJson value yoksa neutral varsayılmalı', () {
      final model = VoteModel.fromJson({}, 'v5');
      expect(model.value, VoteValue.neutral);
    });

    test('toJson value, timedOut, penaltyApplied döndürmeli', () {
      expect(
        VoteModel(voterId: 'x', value: VoteValue.like).toJson(),
        {'value': 'like', 'timedOut': false, 'penaltyApplied': false},
      );
      expect(
        VoteModel(voterId: 'x', value: VoteValue.dislike).toJson(),
        {'value': 'dislike', 'timedOut': false, 'penaltyApplied': false},
      );
    });

    test('round-trip fromJson toJson tutarlı olmalı', () {
      for (final value in VoteValue.values) {
        final model = VoteModel(voterId: 'v', value: value);
        final json = model.toJson();
        final back = VoteModel.fromJson(json, 'v');
        expect(back.value, value);
      }
    });
  });
}
