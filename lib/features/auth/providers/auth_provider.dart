import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_auth_source.dart';
import '../domain/auth_repository.dart';

part 'auth_provider.g.dart';

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
