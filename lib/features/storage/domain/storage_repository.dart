import 'dart:io';

abstract class StorageRepository {
  Future<String> uploadAvatar({
    required String uid,
    required File imageFile,
  });
}
