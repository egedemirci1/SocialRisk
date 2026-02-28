import '../domain/user_entity.dart';

abstract class UserRepository {
  Future<void> createUserProfile(UserEntity user);
  Future<UserEntity?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserEntity user);
  Future<void> updateAvatarUrl(String uid, String avatarUrl);
  Stream<UserEntity?> watchUserProfile(String uid);
}
