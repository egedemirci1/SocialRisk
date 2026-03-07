import '../domain/user_entity.dart';

abstract class UserRepository {
  Future<void> createUserProfile(UserEntity user);
  Future<UserEntity?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserEntity user);
  Future<void> updateAvatarUrl(String uid, String avatarUrl);
  Future<String?> uploadAvatar(String uid, dynamic file);
  Stream<UserEntity?> watchUserProfile(String uid);
  Future<void> reportUser({
    required String reporterId,
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
    required String reason,
  });
  Future<void> updateDisplayName(String uid, String name);
}
