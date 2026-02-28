import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_storage_source.dart';
import '../domain/storage_repository.dart';
import '../../auth/providers/user_provider.dart';

part 'storage_provider.g.dart';

@Riverpod(keepAlive: true)
StorageRepository storageRepository(Ref ref) {
  return FirebaseStorageSource();
}

@riverpod
class StorageController extends _$StorageController {
  @override
  FutureOr<void> build() {}

  Future<String?> uploadAvatar({
    required String uid,
    required File imageFile,
  }) async {
    state = const AsyncLoading();
    try {
      final downloadUrl = await ref.read(storageRepositoryProvider).uploadAvatar(
        uid: uid,
        imageFile: imageFile,
      );
      
      // Update User profile with the new avatarURL
      await ref.read(userControllerProvider.notifier).updateAvatarUrl(uid, downloadUrl);
      
      state = const AsyncData(null);
      return downloadUrl;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}
