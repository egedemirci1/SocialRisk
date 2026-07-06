import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_risk/features/auth/domain/auth_repository.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import '../helpers/fake_user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const UserEntity(uid: 'u1', displayName: 'Test'));
    registerFallbackValue('');
  });

  group('UserController', () {
    test('createUserProfile repository çağrısı yapar', () async {
      final fakeRepo = FakeUserRepository();
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      const user = UserEntity(uid: 'new-user', displayName: 'Yeni');
      await container.read(userControllerProvider.notifier).createUserProfile(user);

      final state = container.read(userControllerProvider);
      expect(state.hasError, isFalse);
    });

    test('updateUserProfile başarılı olunca displayName auth tarafına iletilir', () async {
      final fakeRepo = FakeUserRepository();
      final mockAuth = MockAuthRepository();
      when(() => mockAuth.updateDisplayName(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
          authRepositoryProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      const user = UserEntity(uid: 'test-uid', displayName: 'Güncel');
      await container.read(userControllerProvider.notifier).updateUserProfile(user);

      verify(() => mockAuth.updateDisplayName('Güncel')).called(1);
    });

    test('updateDisplayName hem repo hem auth günceller', () async {
      final fakeRepo = FakeUserRepository();
      final mockAuth = MockAuthRepository();
      when(() => mockAuth.updateDisplayName(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
          authRepositoryProvider.overrideWithValue(mockAuth),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(userControllerProvider.notifier)
          .updateDisplayName('test-uid', 'Ada');

      verify(() => mockAuth.updateDisplayName('Ada')).called(1);
    });

    test('reportUser kullanıcı yoksa sessizce döner', () async {
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          currentUserProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userControllerProvider.notifier).reportUser(
            targetUserId: 't1',
            targetUserName: 'Target',
            targetUserAvatar: '',
            reason: 'spam',
          );

      expect(container.read(userControllerProvider).hasError, isFalse);
    });

    test('reportUser kullanıcı varken repository çağrısı yapar', () async {
      final fakeRepo = _RecordingUserRepository();
      final mockUser = MockUser(uid: 'reporter', isAnonymous: false);

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          currentUserProvider.overrideWithValue(mockUser),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userControllerProvider.notifier).reportUser(
            targetUserId: 'bad',
            targetUserName: 'Bad',
            targetUserAvatar: 'url',
            reason: 'toxic',
          );

      expect(fakeRepo.reportCalls.length, 1);
      expect(fakeRepo.reportCalls.first.reporterId, 'reporter');
      expect(container.read(userControllerProvider).hasError, isFalse);
    });
  });
}

class _RecordingUserRepository extends FakeUserRepository {
  final List<
      ({
        String reporterId,
        String targetUserId,
        String targetUserName,
        String targetUserAvatar,
        String reason,
      })> reportCalls = [];

  @override
  Future<void> reportUser({
    required String reporterId,
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
    required String reason,
  }) async {
    reportCalls.add((
      reporterId: reporterId,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      targetUserAvatar: targetUserAvatar,
      reason: reason,
    ));
  }
}
