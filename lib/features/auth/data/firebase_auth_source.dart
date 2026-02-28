import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import '../data/firebase_user_source.dart';

class FirebaseAuthSource implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signInAnonymously(String displayName) async {
    try {
      final credential = await _auth.signInAnonymously();
      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);

        // E20: Sign in başarılı olunca kullanıcı profilini Global User tablosuna da ekle.
        final userSource = FirebaseUserSource();
        await userSource.createUserProfile(
          UserEntity(
            uid: credential.user!.uid,
            displayName: displayName,
          ),
        );
      }
      return credential;
    } catch (e) {
      throw Exception('Giriş yapılamadı: $e');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }
}
