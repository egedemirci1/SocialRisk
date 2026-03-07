import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';

/// Test için UserController — tüm metodlar no-op.
class FakeUserController extends UserController {
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
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
    required String reason,
  }) async {}

  @override
  Future<void> updateDisplayName(String uid, String name) async {}
}
