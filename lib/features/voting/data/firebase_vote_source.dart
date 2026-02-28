import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/vote_repository.dart';
import 'vote_model.dart';
import '../../shared/models/enums.dart';
import '../../core/constants/game_constants.dart';

class FirebaseVoteSource implements VoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _votesRef(String gameId) =>
      _firestore.collection('games').doc(gameId).collection('votes');

  @override
  Future<void> castVote({
    required String gameId,
    required String voterId,
    required VoteValue value,
  }) async {
    final voteModel = VoteModel(voterId: voterId, value: value);
    await _votesRef(gameId).doc(voterId).set(voteModel.toJson());
  }

  @override
  Stream<Map<String, VoteValue>> watchVotes(String gameId) {
    return _votesRef(gameId).snapshots().map((snapshot) {
      final Map<String, VoteValue> votes = {};
      for (final doc in snapshot.docs) {
        final model = VoteModel.fromJson(doc.data(), doc.id);
        votes[model.voterId] = model.value;
      }
      return votes;
    });
  }

  @override
  Future<int> calculateVoteResult(String gameId) async {
    final snapshot = await _votesRef(gameId).get();
    int totalScore = 0;

    for (final doc in snapshot.docs) {
      final vote = VoteModel.fromJson(doc.data(), doc.id);
      switch (vote.value) {
        case VoteValue.like:
          totalScore += GameConstants.voteMultiplierLike;
          break;
        case VoteValue.neutral:
          totalScore += GameConstants.voteMultiplierNeutral;
          break;
        case VoteValue.dislike:
          totalScore += GameConstants.voteMultiplierDislike;
          break;
      }
    }

    return totalScore;
  }

  @override
  Future<void> clearVotes(String gameId) async {
    final snapshot = await _votesRef(gameId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
