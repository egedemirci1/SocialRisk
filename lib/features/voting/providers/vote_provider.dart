import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_vote_source.dart';
import '../domain/vote_repository.dart';
import '../../../shared/models/enums.dart';

part 'vote_provider.g.dart';

@riverpod
VoteRepository voteRepository(Ref ref) {
  return FirebaseVoteSource();
}

/// watchVotes uses manual StreamProvider because Map<String, VoteValue>
/// causes InvalidTypeException with riverpod_generator.
final watchVotesProvider = StreamProvider.family<Map<String, VoteValue>, String>(
  (ref, gameId) {
    return ref.watch(voteRepositoryProvider).watchVotes(gameId);
  },
);

@riverpod
class VoteController extends _$VoteController {
  @override
  FutureOr<void> build() {}

  Future<void> castVote({
    required String gameId,
    required String voterId,
    required VoteValue value,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(voteRepositoryProvider).castVote(
        gameId: gameId,
        voterId: voterId,
        value: value,
      ),
    );
  }

  /// Oyları topla, çarpanla hesapla → finalScore = votingResult × multiplier
  Future<int> calculateAndApplyScore({
    required String gameId,
    required int taskMultiplier,
  }) async {
    final repo = ref.read(voteRepositoryProvider);
    final voteResult = await repo.calculateVoteResult(gameId);
    final finalScore = voteResult * taskMultiplier * 100;

    await repo.clearVotes(gameId);

    return finalScore;
  }
}
