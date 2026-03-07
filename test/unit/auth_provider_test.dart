import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_risk/features/auth/domain/auth_repository.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Mock: Gerçek Firebase Authentication'a istek atmamak için AuthRepository
// mocklanıyor. ProviderContainer overrides ile enjekte edilecek.
// ---------------------------------------------------------------------------
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue('');
  });

  group('authRepositoryProvider', () {
    test('override ile mock enjekte edildiğinde container mock döndürür', () {
      final mockRepo = MockAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      expect(container.read(authRepositoryProvider), same(mockRepo));
    });
  });

  group('authStateChangesProvider', () {
    test('repository stream null emit ettiğinde state null olur', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      container.read(authStateChangesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(authStateChangesProvider);
      expect(state.hasError, isFalse);
      expect(state.value, isNull);
    });

    test('repository stream user emit ettiğinde state user olur', () async {
      final mockUser = MockUser(uid: 'u1', isAnonymous: true, displayName: 'Test');
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(mockUser));
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<User?>>[];
      container.listen(
        authStateChangesProvider,
        (prev, next) => states.add(next),
        fireImmediately: true,
      );
      container.read(authStateChangesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.any((s) => s.hasValue && s.value == mockUser), isTrue);
      expect(container.read(authStateChangesProvider).value, mockUser);
    });

    test('repository stream exception atınca state error taşır', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer(
        (_) => Stream.error(Exception('Auth stream hatası')),
      );
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      container.listen(
        authStateChangesProvider,
        (_, __) {},
        fireImmediately: true,
      );
      container.read(authStateChangesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(authStateChangesProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
    });
  });

  group('currentUserProvider', () {
    test('authStateChanges null iken currentUser null', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      container.read(authStateChangesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(container.read(currentUserProvider), isNull);
    });

    test('authStateChanges user emit ettiğinde currentUser dolu', () async {
      final mockUser = MockUser(uid: 'u1', isAnonymous: true, displayName: 'Ali');
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(mockUser));
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      container.listen(
        authStateChangesProvider,
        (_, __) {},
        fireImmediately: true,
      );
      container.read(authStateChangesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(container.read(currentUserProvider), mockUser);
      expect(container.read(currentUserProvider)?.uid, 'u1');
    });
  });

  group('AuthController', () {
    test('başlangıç durumu: build sonrası hasError yok', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
      when(() => mockRepo.signInAnonymously(any())).thenAnswer((_) async => null);
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      final state = container.read(authControllerProvider);
      expect(state.hasError, isFalse);
    });

    test('başarılı giriş: signIn çağrılınca repo.signInAnonymously tetiklenir ve state hata taşımaz', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
      when(() => mockRepo.signInAnonymously(any())).thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<void>>[];
      container.listen(
        authControllerProvider,
        (prev, next) => states.add(next),
        fireImmediately: true,
      );

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('Oyuncu');

      expect(container.read(authControllerProvider).hasError, isFalse);
      verify(() => mockRepo.signInAnonymously('Oyuncu')).called(1);
    });

    test('çıkış: logout çağrılınca repo.signOut tetiklenir ve state hata taşımaz', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
      when(() => mockRepo.signOut()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.logout();

      expect(container.read(authControllerProvider).hasError, isFalse);
      verify(() => mockRepo.signOut()).called(1);
    });

    test('hata yönetimi: signIn sırasında repo exception atınca state error', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
      when(() => mockRepo.signInAnonymously(any())).thenThrow(Exception('Ağ hatası'));

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('Oyuncu');

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
      verify(() => mockRepo.signInAnonymously('Oyuncu')).called(1);
    });

    test('hata yönetimi: logout sırasında repo exception atınca state error', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
      when(() => mockRepo.signOut()).thenThrow(Exception('Çıkış hatası'));

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.logout();

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
      verify(() => mockRepo.signOut()).called(1);
    });
  });
}
