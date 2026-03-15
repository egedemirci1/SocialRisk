// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameRepository)
final gameRepositoryProvider = GameRepositoryProvider._();

final class GameRepositoryProvider
    extends $FunctionalProvider<GameRepository, GameRepository, GameRepository>
    with $Provider<GameRepository> {
  GameRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameRepositoryHash();

  @$internal
  @override
  $ProviderElement<GameRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GameRepository create(Ref ref) {
    return gameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameRepository>(value),
    );
  }
}

String _$gameRepositoryHash() => r'47977e8e0277badfa964bc08ef64fccc29d5fa55';

@ProviderFor(watchGame)
final watchGameProvider = WatchGameFamily._();

final class WatchGameProvider
    extends
        $FunctionalProvider<
          AsyncValue<GameEntity?>,
          GameEntity?,
          Stream<GameEntity?>
        >
    with $FutureModifier<GameEntity?>, $StreamProvider<GameEntity?> {
  WatchGameProvider._({
    required WatchGameFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchGameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchGameHash();

  @override
  String toString() {
    return r'watchGameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<GameEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<GameEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return watchGame(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchGameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchGameHash() => r'150035e49c5711b1fd547df760a11cebe32ec9fa';

final class WatchGameFamily extends $Family
    with $FunctionalFamilyOverride<Stream<GameEntity?>, String> {
  WatchGameFamily._()
    : super(
        retry: null,
        name: r'watchGameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchGameProvider call(String gameId) =>
      WatchGameProvider._(argument: gameId, from: this);

  @override
  String toString() => r'watchGameProvider';
}

@ProviderFor(GameController)
final gameControllerProvider = GameControllerProvider._();

final class GameControllerProvider
    extends $AsyncNotifierProvider<GameController, void> {
  GameControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameControllerHash();

  @$internal
  @override
  GameController create() => GameController();
}

String _$gameControllerHash() => r'24682c8d23a64256e27a0b649bef7013a089817a';

abstract class _$GameController extends $AsyncNotifier<void> {
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
