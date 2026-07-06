import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_auth_source.dart';
import '../domain/auth_repository.dart';
import '../constants/auth_constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'auth_provider.g.dart';

/// iOS / macOS dışında Apple girişi desteklenmez.
bool get supportsAppleSignIn =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthSource();
}

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  // authStateChangesProvider'ı watch edelim ki isim değişikliklerinde UI yenilensin
  final authState = ref.watch(authStateChangesProvider);
  return authState.value;
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String name) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => repo.signInAnonymously(name));
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => repo.signOut());
  }
}

/// Google ile giriş yapan callback. Testte override edilerek iptal veya hata simüle edilir.
final signInWithGoogleCallbackProvider = Provider<Future<UserCredential> Function()>((ref) {
  return () async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return FirebaseAuth.instance.signInWithPopup(provider);
    }
    final googleSignIn = GoogleSignIn(serverClientId: kGoogleSignInWebClientId);
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google giriş iptal edildi');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  };
});

/// Apple ile giriş yapan callback. Yalnızca iOS/macOS'ta kullanılır.
final signInWithAppleCallbackProvider =
    Provider<Future<UserCredential> Function()>((ref) {
  return () async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    return FirebaseAuth.instance.signInWithCredential(oauthCredential);
  };
});
