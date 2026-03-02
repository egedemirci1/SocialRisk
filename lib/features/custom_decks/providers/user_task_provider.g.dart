// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userTaskSource)
final userTaskSourceProvider = UserTaskSourceProvider._();

final class UserTaskSourceProvider
    extends
        $FunctionalProvider<
          FirebaseUserTaskSource,
          FirebaseUserTaskSource,
          FirebaseUserTaskSource
        >
    with $Provider<FirebaseUserTaskSource> {
  UserTaskSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userTaskSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userTaskSourceHash();

  @$internal
  @override
  $ProviderElement<FirebaseUserTaskSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseUserTaskSource create(Ref ref) {
    return userTaskSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseUserTaskSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseUserTaskSource>(value),
    );
  }
}

String _$userTaskSourceHash() => r'65a200c21080b4a0339935cf3d73a91f356c335b';

@ProviderFor(watchCustomTasks)
final watchCustomTasksProvider = WatchCustomTasksFamily._();

final class WatchCustomTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserTaskEntity>>,
          List<UserTaskEntity>,
          Stream<List<UserTaskEntity>>
        >
    with
        $FutureModifier<List<UserTaskEntity>>,
        $StreamProvider<List<UserTaskEntity>> {
  WatchCustomTasksProvider._({
    required WatchCustomTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchCustomTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchCustomTasksHash();

  @override
  String toString() {
    return r'watchCustomTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<UserTaskEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<UserTaskEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return watchCustomTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchCustomTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchCustomTasksHash() => r'6b5f6c0af649be08055dd4a769826582255374dd';

final class WatchCustomTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<UserTaskEntity>>, String> {
  WatchCustomTasksFamily._()
    : super(
        retry: null,
        name: r'watchCustomTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchCustomTasksProvider call(String uid) =>
      WatchCustomTasksProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchCustomTasksProvider';
}

@ProviderFor(CustomTaskController)
final customTaskControllerProvider = CustomTaskControllerProvider._();

final class CustomTaskControllerProvider
    extends $AsyncNotifierProvider<CustomTaskController, void> {
  CustomTaskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customTaskControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customTaskControllerHash();

  @$internal
  @override
  CustomTaskController create() => CustomTaskController();
}

String _$customTaskControllerHash() =>
    r'641a77d99b15597024ecda4d6d2327c795d711c4';

abstract class _$CustomTaskController extends $AsyncNotifier<void> {
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
