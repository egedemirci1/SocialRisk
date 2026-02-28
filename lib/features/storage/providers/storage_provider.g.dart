// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storageRepository)
final storageRepositoryProvider = StorageRepositoryProvider._();

final class StorageRepositoryProvider
    extends
        $FunctionalProvider<
          StorageRepository,
          StorageRepository,
          StorageRepository
        >
    with $Provider<StorageRepository> {
  StorageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageRepositoryHash();

  @$internal
  @override
  $ProviderElement<StorageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StorageRepository create(Ref ref) {
    return storageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageRepository>(value),
    );
  }
}

String _$storageRepositoryHash() => r'9073a2d22b93a4e15b52fbd4002142df409d1b0c';

@ProviderFor(StorageController)
final storageControllerProvider = StorageControllerProvider._();

final class StorageControllerProvider
    extends $AsyncNotifierProvider<StorageController, void> {
  StorageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageControllerHash();

  @$internal
  @override
  StorageController create() => StorageController();
}

String _$storageControllerHash() => r'd1fba71bd9977476ba155f51d24c26c08407e9dc';

abstract class _$StorageController extends $AsyncNotifier<void> {
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
