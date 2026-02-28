// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(voteRepository)
final voteRepositoryProvider = VoteRepositoryProvider._();

final class VoteRepositoryProvider
    extends $FunctionalProvider<VoteRepository, VoteRepository, VoteRepository>
    with $Provider<VoteRepository> {
  VoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voteRepositoryHash();

  @$internal
  @override
  $ProviderElement<VoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VoteRepository create(Ref ref) {
    return voteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoteRepository>(value),
    );
  }
}

String _$voteRepositoryHash() => r'2585596e9cf3e1c7c31582d6b00d6d1a6f99904b';

@ProviderFor(VoteController)
final voteControllerProvider = VoteControllerProvider._();

final class VoteControllerProvider
    extends $AsyncNotifierProvider<VoteController, void> {
  VoteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voteControllerHash();

  @$internal
  @override
  VoteController create() => VoteController();
}

String _$voteControllerHash() => r'afa6597dee7f7cb4d767084fbe3d25c54304b610';

abstract class _$VoteController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
