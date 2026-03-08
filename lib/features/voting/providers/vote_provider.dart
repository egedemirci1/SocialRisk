import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_vote_source.dart';
import '../domain/vote_repository.dart';
import '../../../shared/models/enums.dart';

part 'vote_provider.g.dart';

@Riverpod(keepAlive: true)
VoteRepository voteRepository(Ref ref) {
  return FirebaseVoteSource();
}

/// watchVotes uses manual StreamProvider because Map
/// causes InvalidTypeException with riverpod_generator.
final watchVotesProvider = StreamProvider.family<Map<String, VoteValue>, String>(
  (ref, gameId) {
    return ref.watch(voteRepositoryProvider).watchVotes(gameId);
  },
);

@Riverpod(keepAlive: true)
class VoteController extends _$VoteController {
  @override
  FutureOr<void> build() {}

  Future<void> castVote({
    required String gameId,
    required String voterId,
    required VoteValue value,
    bool timedOut = false,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(voteRepositoryProvider).castVote(
        gameId: gameId,
        voterId: voterId,
        value: value,
        timedOut: timedOut,
      ),
    );
  }

  /// Oyları topla, repo içindeki çarpan kurallarıyla nihai puanı hesapla
  Future<List<String>> applyTimedOutPenalties({
    required String gameId,
    required String roomId,
    int penalty = 10,
  }) async {
    return ref.read(voteRepositoryProvider).applyTimedOutPenalties(
      gameId,
      roomId,
      penalty: penalty,
    );
  }

  Future<int> calculateAndApplyScore({
    required String gameId,
    required int taskMultiplier,
  }) async {
    final repo = ref.read(voteRepositoryProvider);
    final finalScore = await repo.calculateVoteResult(gameId, taskMultiplier: taskMultiplier);

    await repo.clearVotes(gameId);

    return finalScore;
  }
}

