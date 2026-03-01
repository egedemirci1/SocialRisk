import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/user_entity.dart';
import '../domain/user_repository.dart';
import 'user_model.dart';

class FirebaseUserSource implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _usersRef() =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _usersRef().doc(uid);

  @override
  Future<void> createUserProfile(UserEntity user) async {
    final doc = await _userDoc(user.uid).get();
    if (doc.exists) return; // Zaten varsa ezme

    final model = UserModel(
      uid: user.uid,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      walletPoints: user.walletPoints,
      rank: user.rank,
      updatedAt: DateTime.now(),
    );

    await _userDoc(user.uid).set(model.toJson());
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
  Future<void> updateAvatarUrl(String uid, String avatarUrl) async {
    await _userDoc(uid).set({
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<String?> uploadAvatar(String uid, dynamic fileData) async {
    try {
      // 1. Eski profil URL'sini al
      final oldProfile = await getUserProfile(uid);
      final oldAvatarUrl = oldProfile?.avatarUrl;

      // 2. Yeni resim için benzersiz isim oluştur (Cache Buster)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance.ref().child('avatars/${uid}_$timestamp.jpg');
      
      UploadTask uploadTask;
      if (fileData is Uint8List) {
        uploadTask = storageRef.putData(fileData, SettableMetadata(contentType: 'image/jpeg'));
      } else if (fileData is File) {
        uploadTask = storageRef.putFile(fileData);
      } else {
        throw Exception('Geçersiz dosya formatı (Uint8List veya File olmalı)');
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update the user's document as well
      await updateAvatarUrl(uid, downloadUrl);
      
      // 3. Eski resmi Storage'dan sil
      if (oldAvatarUrl != null && 
          oldAvatarUrl.isNotEmpty && 
          oldAvatarUrl.startsWith('https://firebasestorage.googleapis.com')) {
        try {
          final oldRef = FirebaseStorage.instance.refFromURL(oldAvatarUrl);
          await oldRef.delete();
        } catch (e) {
          // Eski resim silinirken hata olsa bile, yeni resim yüklendiği için işlemi kesme
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
    final reportRef = FirebaseFirestore.instance.collection('reports').doc();
    await reportRef.set({
      'reporterId': reporterId,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'targetUserAvatar': targetUserAvatar,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
