// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(roomRepository)
final roomRepositoryProvider = RoomRepositoryProvider._();

final class RoomRepositoryProvider
    extends $FunctionalProvider<RoomRepository, RoomRepository, RoomRepository>
    with $Provider<RoomRepository> {
  RoomRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoomRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoomRepository create(Ref ref) {
    return roomRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoomRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoomRepository>(value),
    );
  }
}

String _$roomRepositoryHash() => r'accb57bd0a312cebbef237fe0912153ff287eb18';

@ProviderFor(watchRoom)
final watchRoomProvider = WatchRoomFamily._();

final class WatchRoomProvider
    extends
        $FunctionalProvider<
          AsyncValue<RoomEntity?>,
          RoomEntity?,
          Stream<RoomEntity?>
        >
    with $FutureModifier<RoomEntity?>, $StreamProvider<RoomEntity?> {
  WatchRoomProvider._({
    required WatchRoomFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRoomProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRoomHash();

  @override
  String toString() {
    return r'watchRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<RoomEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RoomEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return watchRoom(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRoomHash() => r'f5270c220fb186ad597b8698439da133a7c20d10';

final class WatchRoomFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RoomEntity?>, String> {
  WatchRoomFamily._()
    : super(
        retry: null,
        name: r'watchRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  WatchRoomProvider call(String roomCode) =>
      WatchRoomProvider._(argument: roomCode, from: this);

  @override
  String toString() => r'watchRoomProvider';
}

@ProviderFor(watchPlayers)
final watchPlayersProvider = WatchPlayersFamily._();

final class WatchPlayersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlayerEntity>>,
          List<PlayerEntity>,
          Stream<List<PlayerEntity>>
        >
    with
        $FutureModifier<List<PlayerEntity>>,
        $StreamProvider<List<PlayerEntity>> {
  WatchPlayersProvider._({
    required WatchPlayersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchPlayersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchPlayersHash();

  @override
  String toString() {
    return r'watchPlayersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PlayerEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PlayerEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return watchPlayers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchPlayersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchPlayersHash() => r'8147f08a2ec4bc23d602016d794d05cb527d8e33';

final class WatchPlayersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PlayerEntity>>, String> {
  WatchPlayersFamily._()
    : super(
        retry: null,
        name: r'watchPlayersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  WatchPlayersProvider call(String roomCode) =>
      WatchPlayersProvider._(argument: roomCode, from: this);

  @override
  String toString() => r'watchPlayersProvider';
}

@ProviderFor(RoomController)
final roomControllerProvider = RoomControllerProvider._();

final class RoomControllerProvider
    extends $AsyncNotifierProvider<RoomController, String?> {
  RoomControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomControllerHash();

  @$internal
  @override
  RoomController create() => RoomController();
}

String _$roomControllerHash() => r'4aae508d37ac668094550a602c70cfc70cd9f39b';

abstract class _$RoomController extends $AsyncNotifier<String?> {
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
