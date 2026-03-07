import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/vote_repository.dart';
import 'vote_model.dart';
import '../../../shared/models/enums.dart';

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
  Future<int> calculateVoteResult(
    String gameId, {
    int taskMultiplier = 1,
  }) async {
    // Oyun modunu ve pazar değerini öğrenmek için oyunu çek
    final gameSnap = await _firestore.collection('games').doc(gameId).get();
    if (!gameSnap.exists) return 0;

    final gameData = gameSnap.data()!;
    final mode = gameData['mode'] as String?;
    final selectedCategory = gameData['selectedCategory'] as String?;
    final marketValues = gameData['categoryMarketValues'] as Map<String, dynamic>? ?? {};

    // 10 Taban Puanı Koruma Hattı (Classic vs Economy)
    int baseScore = 10; // Varsayılan (Classic)

    if (mode == 'economy' && selectedCategory != null) {
      baseScore = marketValues[selectedCategory] as int? ?? 10;
    }

    final snapshot = await _votesRef(gameId).get();
    int totalScore = 0;

    for (final doc in snapshot.docs) {
      final vote = VoteModel.fromJson(doc.data(), doc.id);
      switch (vote.value) {
        case VoteValue.like:
          // Beğendim: Dinamik (veya Klasik 10) taban puan * multiplier
          totalScore += (baseScore * taskMultiplier);
          break;
        case VoteValue.neutral:
          totalScore += 0;
          break;
        case VoteValue.dislike:
          // Beğenmedim: Sabit -10 (Klasik modda da böyle kalsın denmişti)
          totalScore -= 10;
          break;
      }
    }

    return totalScore;
  }

  @override
  Future<void> clearVotes(String gameId) async {
    final snapshot = await _votesRef(gameId).get();
    if (snapshot.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
