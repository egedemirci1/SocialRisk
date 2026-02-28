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
        isAutoDispose: true,
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

String _$gameRepositoryHash() => r'164f31e9691e694fb6867c6b96bc8dffbf7b2539';

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

String _$watchGameHash() => r'2e618f7d95b8c4a6afd067e9218b9161550496ff';

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
    extends $AsyncNotifierProvider<GameController, String?> {
  GameControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameControllerHash();

  @$internal
  @override
  GameController create() => GameController();
}

String _$gameControllerHash() => r'1776324be01fce3f1c0517899daa238d8597fc08';

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
