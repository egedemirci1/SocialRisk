import '../../../shared/models/enums.dart';

abstract class VoteRepository {
  Future<void> castVote({
    required String gameId,
    required String voterId,
    required VoteValue value,
  });

  Stream<Map<String, VoteValue>> watchVotes(String gameId);

  Future<int> calculateVoteResult(String gameId, {int taskMultiplier = 1});

  Future<void> clearVotes(String gameId);
}
