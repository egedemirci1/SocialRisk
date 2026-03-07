import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/domain/user_repository.dart';
import 'package:social_risk/features/auth/domain/auth_repository.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import '../helpers/fake_user_repository.dart';

// ---------------------------------------------------------------------------
// Mock sınıfları: Gerçek Firebase'e istek atmamak için dış bağımlılıkları
// Mocktail ile taklit ediyoruz. ProviderContainer overrides ile enjekte edilecek.
// ---------------------------------------------------------------------------

class MockUserRepository extends Mock implements UserRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const UserEntity(uid: '', displayName: ''),
    );
  });

  group('userRepositoryProvider', () {
    test('override ile mock enjekte edildiğinde container mock döndürür', () {
      final mockRepo = MockUserRepository();
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(userRepositoryProvider), same(mockRepo));
    });
  });

  group('watchUserProfileProvider', () {
    test('başlangıçta stream henüz emit etmeden loading olabilir', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.watchUserProfile(any())).thenAnswer(
        (_) => Stream.value(const UserEntity(uid: 'u1', displayName: 'Test')),
      );
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<UserEntity?>>[];
      container.listen(
        watchUserProfileProvider('u1'),
        (prev, next) => states.add(next),
        fireImmediately: true,
      );
      container.read(watchUserProfileProvider('u1'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.any((s) => s.hasValue), isTrue);
      final dataState = states.last;
      expect(dataState.value?.uid, 'u1');
      expect(dataState.value?.displayName, 'Test');
    });

    test('repository geçerli kullanıcı döndürdüğünde state güncellenir (happy path)', () async {
      const user = UserEntity(
        uid: 'profile-uid',
        displayName: 'Profil Kullanıcı',
        walletPoints: 1000,
        ownedCosmetics: [],
      );
      final fakeRepo = FakeUserRepository(profile: user);
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      // Provider'ı canlı tutmak ve state değişimini almak için listen kullanıyoruz
      final states = <AsyncValue<UserEntity?>>[];
      container.listen(
        watchUserProfileProvider('profile-uid'),
        (prev, next) => states.add(next),
        fireImmediately: true,
      );
      container.read(watchUserProfileProvider('profile-uid'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final state = container.read(watchUserProfileProvider('profile-uid'));
      expect(state.hasError, isFalse);
      expect(state.value, user, reason: 'state.value null; states: $states');
      expect(state.value?.displayName, 'Profil Kullanıcı');
    });

    test('repository null döndürdüğünde state null (logged out / kullanıcı yok)', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.watchUserProfile(any())).thenAnswer((_) => Stream.value(null));
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(watchUserProfileProvider('unknown-uid'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(watchUserProfileProvider('unknown-uid'));
      expect(state.hasError, isFalse);
      expect(state.value, isNull);
    });

    test('repository exception fırlattığında state hata taşır (error handling)', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.watchUserProfile(any())).thenAnswer(
        (_) => Stream.error(Exception('Ağ hatası')),
      );
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<UserEntity?>>[];
      container.listen(
        watchUserProfileProvider('u1'),
        (prev, next) => states.add(next),
        fireImmediately: true,
      );
      container.read(watchUserProfileProvider('u1'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.any((s) => s.hasError), isTrue);
      final last = container.read(watchUserProfileProvider('u1'));
      expect(last.hasError, isTrue);
      expect(last.error, isA<Exception>());
    });
  });

  group('UserController', () {
    test('başlangıç durumu: build sonrası state loading değil, hasError yok', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.createUserProfile(any())).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userControllerProvider.future);
      final state = container.read(userControllerProvider);
      expect(state.hasError, isFalse);
    });

    test('createUserProfile başarılı: repo tamamlanınca state hata taşımaz', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.createUserProfile(any())).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<void>>[];
      container.listen(
        userControllerProvider,
        (prev, next) => states.add(next),
        fireImmediately: true,
      );

      final controller = container.read(userControllerProvider.notifier);
      await controller.createUserProfile(
        const UserEntity(uid: 'u1', displayName: 'Yeni Kullanıcı'),
      );

      expect(container.read(userControllerProvider).hasError, isFalse);
      verify(() => mockRepo.createUserProfile(any())).called(1);
    });

    test('createUserProfile repo exception atınca state error', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.createUserProfile(any())).thenThrow(Exception('Firebase hatası'));
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.createUserProfile(
        const UserEntity(uid: 'u1', displayName: 'Test'),
      );

      final state = container.read(userControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
    });

    test('updateUserProfile başarılı: repo ve auth.updateDisplayName çağrılır', () async {
      final mockRepo = MockUserRepository();
      final mockAuth = MockAuthRepository();
      when(() => mockRepo.updateUserProfile(any())).thenAnswer((_) async {});
      when(() => mockAuth.updateDisplayName(any())).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      const user = UserEntity(uid: 'u1', displayName: 'Güncel İsim');
      final controller = container.read(userControllerProvider.notifier);
      await controller.updateUserProfile(user);

      expect(container.read(userControllerProvider).hasError, isFalse);
      verify(() => mockRepo.updateUserProfile(user)).called(1);
      verify(() => mockAuth.updateDisplayName('Güncel İsim')).called(1);
    });

    test('updateUserProfile repo hata atınca state error, auth güncellenmez', () async {
      final mockRepo = MockUserRepository();
      final mockAuth = MockAuthRepository();
      when(() => mockRepo.updateUserProfile(any())).thenThrow(Exception('Ağ hatası'));
      when(() => mockAuth.updateDisplayName(any())).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.updateUserProfile(
        const UserEntity(uid: 'u1', displayName: 'Test'),
      );

      expect(container.read(userControllerProvider).hasError, isTrue);
      verifyNever(() => mockAuth.updateDisplayName(any()));
    });

    test('updateAvatarUrl başarılı', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.updateAvatarUrl(any(), any())).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.updateAvatarUrl('u1', 'https://example.com/photo.jpg');

      expect(container.read(userControllerProvider).hasError, isFalse);
      verify(() => mockRepo.updateAvatarUrl('u1', 'https://example.com/photo.jpg')).called(1);
    });

    test('updateAvatarUrl repo hata atınca state error', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.updateAvatarUrl(any(), any())).thenThrow(Exception('Storage hatası'));
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.updateAvatarUrl('u1', 'url');

      expect(container.read(userControllerProvider).hasError, isTrue);
    });

    test('uploadAvatar başarılı: downloadUrl döner', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.uploadAvatar(any(), any())).thenAnswer((_) async => 'https://storage/url');
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      final url = await controller.uploadAvatar('u1', <int>[1, 2, 3]);

      expect(url, 'https://storage/url');
      expect(container.read(userControllerProvider).hasError, isFalse);
    });

    test('uploadAvatar repo hata atınca exception fırlatır', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.uploadAvatar(any(), any())).thenThrow(Exception('Upload failed'));
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      expect(
        () => controller.uploadAvatar('u1', Object()),
        throwsA(isA<Exception>()),
      );
    });

    test('reportUser currentUser null ise repo.reportUser çağrılmaz', () async {
      final mockRepo = MockUserRepository();
      when(() => mockRepo.reportUser(
        reporterId: any(named: 'reporterId'),
        targetUserId: any(named: 'targetUserId'),
        targetUserName: any(named: 'targetUserName'),
        targetUserAvatar: any(named: 'targetUserAvatar'),
        reason: any(named: 'reason'),
      )).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          currentUserProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.reportUser(
        targetUserId: 'target',
        targetUserName: 'Target',
        targetUserAvatar: '',
        reason: 'spam',
      );

      verifyNever(() => mockRepo.reportUser(
        reporterId: any(named: 'reporterId'),
        targetUserId: any(named: 'targetUserId'),
        targetUserName: any(named: 'targetUserName'),
        targetUserAvatar: any(named: 'targetUserAvatar'),
        reason: any(named: 'reason'),
      ));
    });

    test('reportUser currentUser set ise repo.reportUser çağrılır', () async {
      final mockUser = MockUser(uid: 'reporter-uid', isAnonymous: false);
      final mockRepo = MockUserRepository();
      when(() => mockRepo.reportUser(
        reporterId: any(named: 'reporterId'),
        targetUserId: any(named: 'targetUserId'),
        targetUserName: any(named: 'targetUserName'),
        targetUserAvatar: any(named: 'targetUserAvatar'),
        reason: any(named: 'reason'),
      )).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          currentUserProvider.overrideWithValue(mockUser),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.reportUser(
        targetUserId: 'target-id',
        targetUserName: 'Target Name',
        targetUserAvatar: 'https://avatar',
        reason: 'Spam',
      );

      verify(() => mockRepo.reportUser(
        reporterId: 'reporter-uid',
        targetUserId: 'target-id',
        targetUserName: 'Target Name',
        targetUserAvatar: 'https://avatar',
        reason: 'Spam',
      )).called(1);
    });

    test('reportUser repo hata atınca state error', () async {
      final mockUser = MockUser(uid: 'r', isAnonymous: false);
      final mockRepo = MockUserRepository();
      when(() => mockRepo.reportUser(
        reporterId: any(named: 'reporterId'),
        targetUserId: any(named: 'targetUserId'),
        targetUserName: any(named: 'targetUserName'),
        targetUserAvatar: any(named: 'targetUserAvatar'),
        reason: any(named: 'reason'),
      )).thenThrow(Exception('Report failed'));
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          currentUserProvider.overrideWithValue(mockUser),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.reportUser(
        targetUserId: 't',
        targetUserName: 'T',
        targetUserAvatar: '',
        reason: 'x',
      );

      expect(container.read(userControllerProvider).hasError, isTrue);
    });

    test('updateDisplayName başarılı: repo ve auth güncellenir', () async {
      final mockRepo = MockUserRepository();
      final mockAuth = MockAuthRepository();
      when(() => mockRepo.updateDisplayName(any(), any())).thenAnswer((_) async {});
      when(() => mockAuth.updateDisplayName(any())).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.updateDisplayName('u1', 'Yeni İsim');

      expect(container.read(userControllerProvider).hasError, isFalse);
      verify(() => mockRepo.updateDisplayName('u1', 'Yeni İsim')).called(1);
      verify(() => mockAuth.updateDisplayName('Yeni İsim')).called(1);
    });

    test('updateDisplayName repo hata atınca state error', () async {
      final mockRepo = MockUserRepository();
      final mockAuth = MockAuthRepository();
      when(() => mockRepo.updateDisplayName(any(), any())).thenThrow(Exception('DB error'));
      when(() => mockAuth.updateDisplayName(any())).thenAnswer((_) async {});
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepo),
          authRepositoryProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(userControllerProvider.notifier);
      await controller.updateDisplayName('u1', 'İsim');

      expect(container.read(userControllerProvider).hasError, isTrue);
      verifyNever(() => mockAuth.updateDisplayName(any()));
    });
  });
}
