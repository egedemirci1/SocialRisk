import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_entity.dart';
import '../domain/user_repository.dart';
import '../data/firebase_user_source.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return FirebaseUserSource();
}

@Riverpod(keepAlive: true)
Stream<UserEntity?> watchUserProfile(Ref ref, String uid) {
  return ref.watch(userRepositoryProvider).watchUserProfile(uid);
}

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  @override
  FutureOr<void> build() {}

  Future<void> createUserProfile(UserEntity user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(userRepositoryProvider).createUserProfile(user)
    );
  }

  Future<void> updateUserProfile(UserEntity user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(userRepositoryProvider).updateUserProfile(user)
    );
  }

  Future<void> updateAvatarUrl(String uid, String avatarUrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(userRepositoryProvider).updateAvatarUrl(uid, avatarUrl)
    );
  }
}
