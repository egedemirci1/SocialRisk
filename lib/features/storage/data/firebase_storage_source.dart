import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/storage_repository.dart';

class FirebaseStorageSource implements StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadAvatar({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('users/$uid/avatar.jpg');
      
      // Upload task
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Avatar yüklenemedi: $e');
    }
  }
}
