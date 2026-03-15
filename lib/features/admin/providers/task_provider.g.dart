// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskSource)
final taskSourceProvider = TaskSourceProvider._();

final class TaskSourceProvider
    extends
        $FunctionalProvider<
          TaskFirestoreSource,
          TaskFirestoreSource,
          TaskFirestoreSource
        >
    with $Provider<TaskFirestoreSource> {
  TaskSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskSourceHash();

  @$internal
  @override
  $ProviderElement<TaskFirestoreSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaskFirestoreSource create(Ref ref) {
    return taskSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskFirestoreSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskFirestoreSource>(value),
    );
  }
}

String _$taskSourceHash() => r'4b43cf9fad2bfdcbf98069e8e46b2db7ca980b76';

@ProviderFor(watchAllTasks)
final watchAllTasksProvider = WatchAllTasksProvider._();

final class WatchAllTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItemEntity>>,
          List<TaskItemEntity>,
          Stream<List<TaskItemEntity>>
        >
    with
        $FutureModifier<List<TaskItemEntity>>,
        $StreamProvider<List<TaskItemEntity>> {
  WatchAllTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskItemEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskItemEntity>> create(Ref ref) {
    return watchAllTasks(ref);
  }
}

String _$watchAllTasksHash() => r'd4b866beefe4da7e11c89f4f96f927857ad02bb1';

@ProviderFor(TaskController)
final taskControllerProvider = TaskControllerProvider._();

final class TaskControllerProvider
    extends $AsyncNotifierProvider<TaskController, void> {
  TaskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskControllerHash();

  @$internal
  @override
  TaskController create() => TaskController();
}

String _$taskControllerHash() => r'deae25eb1925caadda7375272c3361202ecd74a0';

abstract class _$TaskController extends $AsyncNotifier<void> {
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
