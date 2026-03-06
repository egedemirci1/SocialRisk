import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_entity.dart';
import '../domain/user_repository.dart';
import '../data/firebase_user_source.dart';
import 'auth_provider.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return FirebaseUserSource();
}

@riverpod
Stream<UserEntity?> watchUserProfile(Ref ref, String uid) {
  return ref.watch(userRepositoryProvider).watchUserProfile(uid);
}

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  @override
  FutureOr<void> build() {}

  Future<void> createUserProfile(UserEntity user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).createUserProfile(user),
    );
  }

  Future<void> updateUserProfile(UserEntity user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).updateUserProfile(user),
    );
    if (!state.hasError) {
      await ref.read(authRepositoryProvider).updateDisplayName(user.displayName);
    }
  }

  Future<void> updateAvatarUrl(String uid, String avatarUrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).updateAvatarUrl(uid, avatarUrl),
    );
  }

  Future<String?> uploadAvatar(String uid, dynamic file) async {
    state = const AsyncLoading();
    String? downloadUrl;
    state = await AsyncValue.guard(() async {
      downloadUrl = await ref
          .read(userRepositoryProvider)
          .uploadAvatar(uid, file);
    });
    // Eğer hata alındıysa, sessizce geçiştirmek yerine UI'a hatayı fırlat
    if (state.hasError) {
      throw state.error!;
    }
    return downloadUrl;
  }

  Future<void> reportUser({
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
    required String reason,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(userRepositoryProvider)
          .reportUser(
            reporterId: user.uid,
            targetUserId: targetUserId,
            targetUserName: targetUserName,
            targetUserAvatar: targetUserAvatar,
            reason: reason,
          ),
    );
  }
}
