import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/domain/user_repository.dart';

/// Test için UserRepository — watchUserProfile ve getUserProfile sahte veri döndürür.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({UserEntity? profile}) : _profile = profile ?? _defaultProfile;

  static final UserEntity _defaultProfile = UserEntity(
    uid: 'test-uid',
    displayName: 'Test User',
    walletPoints: 1000,
    ownedCosmetics: [],
  );

  UserEntity _profile;

  void setProfile(UserEntity p) => _profile = p;

  @override
  Stream<UserEntity?> watchUserProfile(String uid) => Stream.value(_profile);

  @override
  Future<UserEntity?> getUserProfile(String uid) async => _profile;

  @override
  Future<void> createUserProfile(UserEntity user) async {}

  @override
  Future<void> updateUserProfile(UserEntity user) async {}

  @override
  Future<void> updateAvatarUrl(String uid, String avatarUrl) async {}

  @override
  Future<String?> uploadAvatar(String uid, dynamic file) async => null;

  @override
  Future<void> reportUser({
    required String reporterId,
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
    required String reason,
  }) async {}

  @override
  Future<void> updateDisplayName(String uid, String name) async {}

  @override
  Future<void> deleteUserProfileAndAvatar(String uid) async {}
}
