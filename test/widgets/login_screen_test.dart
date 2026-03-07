import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:social_risk/features/auth/domain/auth_repository.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/domain/user_repository.dart';
import 'package:social_risk/features/auth/presentation/login_screen.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import 'package:social_risk/shared/widgets/common/social_risk_logo.dart';

// ---------------------------------------------------------------------------
// Mock: Gerçek Firebase kullanmamak için AuthRepository mocklanıyor;
// signInAnonymously çağrısını verify edeceğiz.
// ---------------------------------------------------------------------------
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

/// Fake UserCredential for social sign-in tests.
class FakeUserCredential implements UserCredential {
  FakeUserCredential(this.user);
  @override
  final User? user;
  @override
  AuthCredential? get credential => null;
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
}

UserCredential fakeUserCredential({String uid = 'google-uid', String? displayName = 'Google User'}) {
  final user = MockUser(uid: uid, isAnonymous: false, displayName: displayName);
  return FakeUserCredential(user);
}

/// Fake auth repository for widget tests — no Firebase calls.
class FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential?> signInAnonymously(String displayName) async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}
}

/// Giriş işlemi tamamlanmayan repo — loading state testi için.
class DelayedFakeAuthRepository implements AuthRepository {
  final Completer<UserCredential?> _completer = Completer<UserCredential?>();

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential?> signInAnonymously(String displayName) async =>
      _completer.future;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}
}

/// signIn çağrıldığında hata fırlatan controller — ekranda hata mesajı testi için.
class _ThrowingAuthController extends AuthController {
  @override
  Future<void> signIn(String name) async {
    throw Exception('Ağ hatası');
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(const UserEntity(uid: '', displayName: ''));
  });

  group('LoginScreen', () {
    Widget buildTestWidget({
      AuthRepository? authRepository,
      AuthController? authController,
    }) {
      final overrides = [
        authRepositoryProvider.overrideWithValue(
          authRepository ?? FakeAuthRepository(),
        ),
      ];
      if (authController != null) {
        overrides.add(authControllerProvider.overrideWith(() => authController));
      }
      return ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(600, 900)),
            child: const LoginScreen(),
          ),
        ),
      );
    }

    testWidgets('sayfa çizimi: logo, Anonim giriş ve Google ile Giriş butonları görünür', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.byType(SocialRiskLogo), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Partiye Katıl!'), findsOneWidget);
      expect(find.text('Google ile Devam Et'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('shows anonymous login hint text', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      expect(
        find.textContaining('Anonim olarak devam edeceksiniz'),
        findsOneWidget,
      );
    });

    testWidgets('shows Google button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.text('Google ile Devam Et'), findsOneWidget);
    });

    testWidgets('shows "Veya" divider', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.text('Veya'), findsOneWidget);
    });

    testWidgets('name field has hint', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.text('Oyuncu Adınız...'), findsOneWidget);
    });

    testWidgets('Anonim Giriş: Partiye Katıl tıklanınca signInAnonymously tetiklenir', (tester) async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
      when(() => mockRepo.signInAnonymously(any())).thenAnswer((_) async => null);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.enterText(find.byType(TextField), 'TestOyuncu');
      await tester.tap(find.text('Partiye Katıl!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      verify(() => mockRepo.signInAnonymously('TestOyuncu')).called(1);
    });

    testWidgets('Google ile Giriş: butona tıklanınca loading overlay görünür', (tester) async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.tap(find.text('Google ile Devam Et'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Partiye giriş yapılıyor...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('loading durumu: anonim giriş sürerken overlay ve indikatör görünür', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget(
        authRepository: DelayedFakeAuthRepository(),
      ));
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.enterText(find.byType(TextField), 'ValidName');
      await tester.tap(find.text('Partiye Katıl!'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Partiye giriş yapılıyor...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('hata durumu: giriş hata verince ekranda hata mesajı belirir', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget(
        authController: _ThrowingAuthController(),
      ));
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.enterText(find.byType(TextField), 'ValidName');
      await tester.tap(find.text('Partiye Katıl!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.textContaining('Giriş başarısız'), findsOneWidget);
      expect(find.textContaining('Ağ hatası'), findsOneWidget);
      // Toast'un 3 sn timer'ının bitmesi için pump et (pending timer hatası önlenir)
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('enter name and tap Partiye Katıl does not crash', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.enterText(find.byType(TextField), 'TestOyuncu');
      await tester.tap(find.text('Partiye Katıl!'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    // ─── Validasyon testleri ─────────────────────────────────────────────
    testWidgets('empty name shows error toast', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.tap(find.text('Partiye Katıl!'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Lütfen sahne adınızı belirleyin'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('short name (<3 chars) shows error toast', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.enterText(find.byType(TextField), 'Ab');
      await tester.tap(find.text('Partiye Katıl!'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('İsim en az 3 karakter olmalıdır'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('invalid chars show error toast', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.enterText(find.byType(TextField), 'Test@123');
      await tester.tap(find.text('Partiye Katıl!'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Sadece harf ve rakam kullanın'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('valid name with Turkish chars is accepted', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.enterText(find.byType(TextField), 'Şölen Oyuncu');
      await tester.tap(find.text('Partiye Katıl!'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Lütfen sahne adınızı belirleyin'), findsNothing);
      expect(find.text('İsim en az 3 karakter olmalıdır'), findsNothing);
      expect(find.text('Sadece harf ve rakam kullanın'), findsNothing);
    });

    // ─── Google giriş iptali ─────────────────────────────────────────────
    testWidgets('Google signIn null (iptal) döndüğünde ekranda "Google giriş iptal edildi" hatası çıkar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            signInWithGoogleCallbackProvider.overrideWithValue(
              () async => throw Exception('Google giriş iptal edildi'),
            ),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.tap(find.text('Google ile Devam Et'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.textContaining('Google giriş iptal edildi'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    // ─── Sosyal giriş sonrası profil hatası ─────────────────────────────
    testWidgets('Sosyal giriş başarılı, createUserProfile hata fırlatınca doğru hata mesajı görünür', (tester) async {
      final mockUserRepo = MockUserRepository();
      when(() => mockUserRepo.createUserProfile(any())).thenThrow(
        Exception('Profil oluşturulamadı'),
      );

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            userRepositoryProvider.overrideWithValue(mockUserRepo),
            signInWithGoogleCallbackProvider.overrideWithValue(
              () async => fakeUserCredential(),
            ),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.tap(find.text('Google ile Devam Et'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.textContaining('Profil oluşturulamadı'), findsOneWidget);
      verify(() => mockUserRepo.createUserProfile(any())).called(1);
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
