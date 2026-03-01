// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'a7580ce3b2347aa156ada98257aaf36f7c8b6be5';

@ProviderFor(watchUserProfile)
final watchUserProfileProvider = WatchUserProfileFamily._();

final class WatchUserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserEntity?>,
          UserEntity?,
          Stream<UserEntity?>
        >
    with $FutureModifier<UserEntity?>, $StreamProvider<UserEntity?> {
  WatchUserProfileProvider._({
    required WatchUserProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchUserProfileProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchUserProfileHash();

  @override
  String toString() {
    return r'watchUserProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return watchUserProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchUserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchUserProfileHash() => r'40d6e3a74453a67f8b4aa12a4dc615495058aa89';

final class WatchUserProfileFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserEntity?>, String> {
  WatchUserProfileFamily._()
    : super(
        retry: null,
        name: r'watchUserProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  WatchUserProfileProvider call(String uid) =>
      WatchUserProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchUserProfileProvider';
}

@ProviderFor(UserController)
final userControllerProvider = UserControllerProvider._();

final class UserControllerProvider
    extends $AsyncNotifierProvider<UserController, void> {
  UserControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userControllerHash();

  @$internal
  @override
  UserController create() => UserController();
}

String _$userControllerHash() => r'c2ff83bbe83e570e4d56b246671b533b42893100';

abstract class _$UserController extends $AsyncNotifier<void> {
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
