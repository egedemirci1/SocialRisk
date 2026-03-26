import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../domain/vote_repository.dart';
import 'vote_model.dart';
import '../../../shared/models/enums.dart';

class FirebaseVoteSource implements VoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> _votesRef(String gameId) =>
      _firestore.collection('games').doc(gameId).collection('votes');

  @override
  Future<void> castVote({
    required String gameId,
    required String voterId,
    required VoteValue value,
    bool timedOut = false,
  }) async {
    final voteModel = VoteModel(
      voterId: voterId,
      value: value,
      timedOut: timedOut,
      penaltyApplied: false,
    );
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
  Future<VoteResult> calculateVoteResult(
    String gameId, {
    int taskMultiplier = 1,
  }) async {
    // Oyun modunu ve pazar değerini öğrenmek için oyunu çek
    final gameSnap = await _firestore.collection('games').doc(gameId).get();
    if (!gameSnap.exists) {
      return const VoteResult(totalScore: 0, audienceScore: 0);
    }

    final gameData = gameSnap.data()!;
    final mode = gameData['mode'] as String?;
    final selectedCategory = gameData['selectedCategory'] as String?;
    final marketValues = gameData['categoryMarketValues'] as Map<String, dynamic>? ?? {};
    final hotCategory = gameData['hotCategory'] as String?;

    int baseScore = 10; // Çark modu (classic)

    if (mode == 'economy' && selectedCategory != null) {
      if (selectedCategory == hotCategory) {
        baseScore = 12; // Sıcak fırsat (Borsa, her tur 1 kategori)
      } else {
        baseScore = marketValues[selectedCategory] as int? ?? 10;
      }
    }

    final snapshot = await _votesRef(gameId).get();
    var likes = 0;
    var neutrals = 0;
    var dislikes = 0;

    for (final doc in snapshot.docs) {
      final vote = VoteModel.fromJson(doc.data(), doc.id);
      if (vote.timedOut) continue;
      switch (vote.value) {
        case VoteValue.like: likes++; break;
        case VoteValue.neutral: neutrals++; break;
        case VoteValue.dislike: dislikes++; break;
      }
    }

    // Tur puanı = base × zorluk (oyuncu sayısı etkilemez). Çoğunluk tek sonucu belirler.
    final fullRoundScore = baseScore * taskMultiplier;
    final mood = likes >= neutrals && likes >= dislikes
        ? 'like'
        : dislikes >= likes && dislikes >= neutrals
            ? 'dislike'
            : 'neutral';

    final totalScore = mood == 'like'
        ? fullRoundScore
        : mood == 'neutral'
            ? fullRoundScore ~/ 2
            : 0;
    final audienceScore = baseScore;

    await _firestore.collection('games').doc(gameId).update({
      'lastRoundMood': mood,
    });

    return VoteResult(
      totalScore: totalScore,
      audienceScore: audienceScore,
    );
  }


  @override
  Future<List<String>> applyTimedOutPenalties(
    String gameId,
    String roomId, {
    int penalty = 10,
  }) async {
    final snapshot = await _votesRef(gameId)
        .where('timedOut', isEqualTo: true)
        .where('penaltyApplied', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    final batch = _firestore.batch();
    final penalizedIds = <String>[];

    for (final doc in snapshot.docs) {
      penalizedIds.add(doc.id);
      batch.update(
        _firestore.collection('rooms').doc(roomId).collection('players').doc(doc.id),
        {'score': FieldValue.increment(-penalty)},
      );
      batch.update(doc.reference, {'penaltyApplied': true});
    }

    await batch.commit();
    return penalizedIds;
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

  @override
  Future<VoteResult> finalizeVotingRound({required String gameId}) async {
    final callable = _functions.httpsCallable('finalizeVotingRound');
    final response = await callable.call(<String, dynamic>{'gameId': gameId});
    final data = Map<String, dynamic>.from(response.data as Map);

    return VoteResult(
      totalScore: data['totalScore'] as int? ?? 0,
      audienceScore: data['audienceScore'] as int? ?? 0,
      mood: data['mood'] as String?,
      penalizedCount: data['penalizedCount'] as int? ?? 0,
    );
  }
}


