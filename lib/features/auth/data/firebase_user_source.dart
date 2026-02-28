import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_entity.dart';
import '../domain/user_repository.dart';
import 'user_model.dart';
import '../../../shared/models/enums.dart'; // Just in case we need enums later

class FirebaseUserSource implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _usersRef() =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _usersRef().doc(uid);

  @override
  Future<void> createUserProfile(UserEntity user) async {
    final doc = await _userDoc(user.uid).get();
    if (doc.exists) return; // Zaten varsa ezme

    final model = UserModel(
      uid: user.uid,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      walletPoints: user.walletPoints,
      rank: user.rank,
      updatedAt: DateTime.now(),
    );

    await _userDoc(user.uid).set(model.toJson());
  }

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;

    final model = UserModel.fromJson(doc.data()!, doc.id);
    return model.toEntity();
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    final model = UserModel(
      uid: user.uid,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      walletPoints: user.walletPoints,
      rank: user.rank,
      updatedAt: DateTime.now(),
    );

    await _userDoc(user.uid).update(model.toJson());
  }

  @override
  Future<void> updateAvatarUrl(String uid, String avatarUrl) async {
    await _userDoc(uid).update({
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<UserEntity?> watchUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!, doc.id).toEntity();
    });
  }
}
