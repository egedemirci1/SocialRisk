import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import '../domain/user_repository.dart';
import 'firebase_user_source.dart';

class FirebaseAuthSource implements AuthRepository {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  FirebaseAuthSource({
    FirebaseAuth? auth,
    UserRepository? userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? FirebaseUserSource();

  @override
  Stream<User?> get authStateChanges => _auth.userChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential?> signInAnonymously(String displayName) async {
    try {
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
        await _auth.currentUser!.updateDisplayName(displayName);
        await _auth.currentUser!.reload();
        await _userRepository.createUserProfile(
          UserEntity(uid: _auth.currentUser!.uid, displayName: displayName),
        );
        return null;
      }

      final credential = await _auth.signInAnonymously();
      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();

        await _userRepository.createUserProfile(
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
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        await _userRepository.deleteUserProfileAndAvatar(user.uid);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Kullanıcı dökümanı/avatar silinirken hata: $e');
        }
      }
    }
    await _auth.signOut();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }
}
