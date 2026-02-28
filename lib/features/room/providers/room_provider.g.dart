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
        isAutoDispose: true,
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

String _$roomRepositoryHash() => r'd6c3e1bbbeffe41de5f346ada0db884d69e48de5';

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
         isAutoDispose: true,
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

String _$watchRoomHash() => r'f91e9642d5e21113030ff86b8f406eb059ba30b9';

final class WatchRoomFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RoomEntity?>, String> {
  WatchRoomFamily._()
    : super(
        retry: null,
        name: r'watchRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
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
         isAutoDispose: true,
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

String _$watchPlayersHash() => r'c7f84aa9432776769485f7f3642bd93a8e5d436e';

final class WatchPlayersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PlayerEntity>>, String> {
  WatchPlayersFamily._()
    : super(
        retry: null,
        name: r'watchPlayersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
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
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomControllerHash();

  @$internal
  @override
  RoomController create() => RoomController();
}

String _$roomControllerHash() => r'a5bc36ca3581fb03e1e6c6b87bf62842e8c79f3e';

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
