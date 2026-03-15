// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'economy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(economyRepository)
final economyRepositoryProvider = EconomyRepositoryProvider._();

final class EconomyRepositoryProvider
    extends
        $FunctionalProvider<
          EconomyRepository,
          EconomyRepository,
          EconomyRepository
        >
    with $Provider<EconomyRepository> {
  EconomyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'economyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$economyRepositoryHash();

  @$internal
  @override
  $ProviderElement<EconomyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EconomyRepository create(Ref ref) {
    return economyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EconomyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EconomyRepository>(value),
    );
  }
}

String _$economyRepositoryHash() => r'cc8eb9d5273e0f18508894f88242de4494316dde';

@ProviderFor(fetchCosmetics)
final fetchCosmeticsProvider = FetchCosmeticsProvider._();

final class FetchCosmeticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CosmeticItemEntity>>,
          List<CosmeticItemEntity>,
          FutureOr<List<CosmeticItemEntity>>
        >
    with
        $FutureModifier<List<CosmeticItemEntity>>,
        $FutureProvider<List<CosmeticItemEntity>> {
  FetchCosmeticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchCosmeticsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchCosmeticsHash();

  @$internal
  @override
  $FutureProviderElement<List<CosmeticItemEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CosmeticItemEntity>> create(Ref ref) {
    return fetchCosmetics(ref);
  }
}

String _$fetchCosmeticsHash() => r'c588059c33fe531aa8901943136824f92bc8ead3';

@ProviderFor(EconomyController)
final economyControllerProvider = EconomyControllerProvider._();

final class EconomyControllerProvider
    extends $AsyncNotifierProvider<EconomyController, void> {
  EconomyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'economyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$economyControllerHash();

  @$internal
  @override
  EconomyController create() => EconomyController();
}

String _$economyControllerHash() => r'22cd30decf6c69b745e9bbe37a88da4845189047';

abstract class _$EconomyController extends $AsyncNotifier<void> {
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
