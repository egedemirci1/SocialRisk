import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<UserCredential?> signInAnonymously(String displayName);
  Future<void> signOut();
  Future<void> updateDisplayName(String displayName);
}
