import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import '../data/firebase_user_source.dart';

class FirebaseAuthSource implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.userChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signInAnonymously(String displayName) async {
    try {
      // Eğer halihazırda anonim veya normal bir oturum varsa, yeni hesap açmak yerine var olanı kullan
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
        // İsim değişikliğini Firestore'a da yansıtmak (veya profil yoksa oluşturmak) için:
        final userSource = FirebaseUserSource();
        await userSource.createUserProfile(
          UserEntity(uid: _auth.currentUser!.uid, displayName: displayName),
        );
        // Not: Mevcut bir oturum varken signInAnonymously() arka arkaya çağrılırsa
        // UserCredential döndüremeyebiliriz (zaten giriş yapıldığı için).
        // Bu yüzden eğer currentUser varsa işlemi AuthProvider tarafında handle edecek şekilde
        // sadece UserCredential bekleyen yerler için yeniden signInAnonymously çağırılır,
        // ancak Firebase zaten var olan anonim oturum kimliğini tekrar döndürür.
      }

      final credential = await _auth.signInAnonymously();
      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);

        // E20: Sign in başarılı olunca kullanıcı profilini Global User tablosuna da ekle.
        final userSource = FirebaseUserSource();
        await userSource.createUserProfile(
          UserEntity(uid: credential.user!.uid, displayName: displayName),
        );
      }
      return credential;
    } catch (e) {
      throw Exception('Giriş yapılamadı: $e');
    }
  }

  @override
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        final collectionRef = FirebaseFirestore.instance.collection('users');
        await collectionRef.doc(user.uid).delete();
      } catch (e) {
        // Silme başarısız olsa bile çıkışa mani olma
        debugPrint('Kullanıcı dökümanı silinirken hata oldu: $e');
      }
    }
    await _auth.signOut();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }
}
