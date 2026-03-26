import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../domain/user_entity.dart';
import '../domain/user_repository.dart';
import 'user_model.dart';

class FirebaseUserSource implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseUserSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _usersRef() =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _usersRef().doc(uid);

  @override
  Future<void> createUserProfile(UserEntity user) async {
    final model = UserModel(
      uid: user.uid,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      walletPoints: user.walletPoints,
      rank: user.rank,
      updatedAt: DateTime.now(),
    );
    await _userDoc(user.uid).set(model.toJson(), SetOptions(merge: true));
  }

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;

    final model = UserModel.fromJson(doc.data()!, doc.id);
    return model.toEntity();
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    await _userDoc(user.uid).set({
      'displayName': user.displayName,
      'avatarUrl': user.avatarUrl,
      'activeFrame': user.activeFrame,
      'activeTitle': user.activeTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateAvatarUrl(String uid, String avatarUrl) async {
    await _userDoc(uid).set({
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<String?> uploadAvatar(String uid, dynamic fileData) async {
    try {
      final oldProfile = await getUserProfile(uid).catchError((_) => null);
      final oldAvatarUrl = oldProfile?.avatarUrl;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref().child(
            'avatars/${uid}_$timestamp.jpg',
          );

      UploadTask uploadTask;
      if (fileData is Uint8List) {
        uploadTask = storageRef.putData(
          fileData,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        throw Exception('Geçersiz dosya formatı (Uint8List olmalı)');
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await updateAvatarUrl(uid, downloadUrl);

      if (oldAvatarUrl != null &&
          oldAvatarUrl.isNotEmpty &&
          oldAvatarUrl.startsWith('https://firebasestorage.googleapis.com')) {
        try {
          final oldRef = _storage.refFromURL(oldAvatarUrl);
          await oldRef.delete();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Eski avatar silinirken hata: $e');
          }
        }
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Profil fotoğrafı yüklenirken hata oluştu: $e');
    }
  }

  @override
  Stream<UserEntity?> watchUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!, doc.id).toEntity();
    });
  }

  @override
  Future<void> reportUser({
    required String reporterId,
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
    required String reason,
  }) async {
    final reportRef = _firestore.collection('reports').doc();
    await reportRef.set({
      'reporterId': reporterId,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'targetUserAvatar': targetUserAvatar,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateDisplayName(String uid, String name) async {
    await _userDoc(uid).set({
      'displayName': name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteUserProfileAndAvatar(String uid) async {
    final profile = await getUserProfile(uid).catchError((_) => null);
    final avatarUrl = profile?.avatarUrl;

    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        avatarUrl.startsWith('https://firebasestorage.googleapis.com')) {
      try {
        final ref = _storage.refFromURL(avatarUrl);
        await ref.delete();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Avatar silinirken hata: $e');
        }
      }
    }

    await _userDoc(uid).delete();
  }

  @override
  Future<void> incrementUserStat(String uid, String statKey, int amount) async {
    await _userDoc(uid).set({
      'stats': {
        statKey: FieldValue.increment(amount)
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
