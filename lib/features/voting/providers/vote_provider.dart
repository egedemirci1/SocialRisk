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
    if (state.hasError) throw state.error!;
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

  Future<VoteResult> calculateAndApplyScore({
    required String gameId,
    required int taskMultiplier,
  }) async {
    final repo = ref.read(voteRepositoryProvider);
    return repo.calculateVoteResult(gameId, taskMultiplier: taskMultiplier);
  }

  Future<void> clearVotes(String gameId) async {
    await ref.read(voteRepositoryProvider).clearVotes(gameId);
  }

  Future<VoteResult> finalizeVotingRound({required String gameId}) async {
    return ref.read(voteRepositoryProvider).finalizeVotingRound(gameId: gameId);
  }
}

