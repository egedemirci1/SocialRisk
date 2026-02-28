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
         isAutoDispose: false,
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

String _$watchGameHash() => r'4c1fb882a71e9347dd9b2313eb45a3c4aef1e731';

final class WatchGameFamily extends $Family
    with $FunctionalFamilyOverride<Stream<GameEntity?>, String> {
  WatchGameFamily._()
    : super(
        retry: null,
        name: r'watchGameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  WatchGameProvider call(String gameId) =>
      WatchGameProvider._(argument: gameId, from: this);

  @override
  String toString() => r'watchGameProvider';
}

@ProviderFor(GameController)
final gameControllerProvider = GameControllerProvider._();

final class GameControllerProvider
    extends $AsyncNotifierProvider<GameController, String?> {
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

String _$gameControllerHash() => r'f5793cfc095772d39b97f472bc01fac4f6b40e92';

abstract class _$GameController extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
