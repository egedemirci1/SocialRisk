import '../../../shared/models/enums.dart';

class VoteResult {
  final int totalScore;
  final int audienceScore;

  const VoteResult({
    required this.totalScore,
    required this.audienceScore,
  });
}

abstract class VoteRepository {
  Future<void> castVote({
    required String gameId,
    required String voterId,
    required VoteValue value,
    bool timedOut = false,
  });

  Stream<Map<String, VoteValue>> watchVotes(String gameId);

  Future<VoteResult> calculateVoteResult(
    String gameId, {
    int taskMultiplier = 1,
  });

  Future<List<String>> applyTimedOutPenalties(
    String gameId,
    String roomId, {
    int penalty = 10,
  });

  Future<void> clearVotes(String gameId);
}

