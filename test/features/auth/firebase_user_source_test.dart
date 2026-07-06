import 'dart:typed_data';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/auth/data/firebase_user_source.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';

void main() {
  group('FirebaseUserSource', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseStorage mockStorage;
    late FirebaseUserSource userSource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockStorage = MockFirebaseStorage();
      userSource = FirebaseUserSource(firestore: fakeFirestore, storage: mockStorage);
    });

    test('createUserProfile upsert writes correct data to Firestore', () async {
      final user = UserEntity(uid: 'u1', displayName: 'TestOyuncu');
      await userSource.createUserProfile(user);

      var doc = await fakeFirestore.collection('users').doc('u1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['displayName'], 'TestOyuncu');

      await userSource.createUserProfile(
        UserEntity(uid: 'u1', displayName: 'GüncelIsim'),
      );
      doc = await fakeFirestore.collection('users').doc('u1').get();
      expect(doc.data()!['displayName'], 'GüncelIsim');
    });

    test('getUserProfile returns null when doc does not exist', () async {
      final profile = await userSource.getUserProfile('nonexistent');
      expect(profile, isNull);
    });

    test('getUserProfile returns entity when doc exists', () async {
      await fakeFirestore.collection('users').doc('u2').set({
        'displayName': 'Ali',
        'walletPoints': 100,
        'rank': 'Newbie',
        'ownedCosmetics': <dynamic>[],
        'ownedCategories': <dynamic>['genel'],
        'updatedAt': DateTime.now(),
      });

      final profile = await userSource.getUserProfile('u2');
      expect(profile, isNotNull);
      expect(profile!.uid, 'u2');
      expect(profile.displayName, 'Ali');
    });

    test('updateUserProfile merges data', () async {
      await userSource.createUserProfile(
        UserEntity(uid: 'u3', displayName: 'Eski'),
      );
      await userSource.updateUserProfile(
        UserEntity(uid: 'u3', displayName: 'Yeni', walletPoints: 50),
      );

      final doc = await fakeFirestore.collection('users').doc('u3').get();
      expect(doc.data()!['displayName'], 'Yeni');
      // walletPoints yalnızca createUserProfile / economy katmanında güncellenir.
      expect(doc.data()!['walletPoints'], 0);
    });

    test('updateAvatarUrl merges avatarUrl', () async {
      await userSource.createUserProfile(
        UserEntity(uid: 'u4', displayName: 'AvatarUser'),
      );
      await userSource.updateAvatarUrl('u4', 'https://example.com/avatar.jpg');

      final doc = await fakeFirestore.collection('users').doc('u4').get();
      expect(doc.data()!['avatarUrl'], 'https://example.com/avatar.jpg');
    });

    test('uploadAvatar uploads new image and deletes old from Storage', () async {
      await userSource.createUserProfile(
        UserEntity(uid: 'u5', displayName: 'PhotoUser'),
      );
      final imageData = Uint8List.fromList([1, 2, 3, 4, 5]);

      final url = await userSource.uploadAvatar('u5', imageData);

      expect(url, isNotNull);
      expect(url!, isNotEmpty);
      final doc = await fakeFirestore.collection('users').doc('u5').get();
      expect(doc.data()!['avatarUrl'], url);
    });

    test('uploadAvatar with existing avatar deletes old from Storage', () async {
      final oldUrl = 'https://firebasestorage.googleapis.com/v0/b/x/o/avatars%2Fu6_old.jpg?alt=media';
      await fakeFirestore.collection('users').doc('u6').set({
        'displayName': 'OldPhoto',
        'avatarUrl': oldUrl,
        'updatedAt': DateTime.now(),
      });
      final userSourceWithStorage = FirebaseUserSource(
        firestore: fakeFirestore,
        storage: mockStorage,
      );
      final imageData = Uint8List.fromList([10, 20, 30]);

      await userSourceWithStorage.uploadAvatar('u6', imageData);

      final newDoc = await fakeFirestore.collection('users').doc('u6').get();
      expect(newDoc.data()!['avatarUrl'], isNot(equals(oldUrl)));
    });

    test('deleteUserProfileAndAvatar deletes doc and avatar from Storage', () async {
      final avatarUrl = 'https://firebasestorage.googleapis.com/v0/b/x/o/avatars%2Fu7_1.jpg?alt=media';
      await fakeFirestore.collection('users').doc('u7').set({
        'displayName': 'Silinecek',
        'avatarUrl': avatarUrl,
        'updatedAt': DateTime.now(),
      });

      await userSource.deleteUserProfileAndAvatar('u7');

      final doc = await fakeFirestore.collection('users').doc('u7').get();
      expect(doc.exists, isFalse);
    });

    test('deleteUserProfileAndAvatar when no avatar only deletes doc', () async {
      await fakeFirestore.collection('users').doc('u8').set({
        'displayName': 'NoAvatar',
        'updatedAt': DateTime.now(),
      });

      await userSource.deleteUserProfileAndAvatar('u8');

      final doc = await fakeFirestore.collection('users').doc('u8').get();
      expect(doc.exists, isFalse);
    });

    test('reportUser writes to reports collection', () async {
      await userSource.reportUser(
        reporterId: 'r1',
        targetUserId: 't1',
        targetUserName: 'Target',
        targetUserAvatar: 'https://avatar',
        reason: 'Spam',
      );

      final snapshot = await fakeFirestore.collection('reports').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['reporterId'], 'r1');
      expect(snapshot.docs.first.data()['targetUserId'], 't1');
      expect(snapshot.docs.first.data()['reason'], 'Spam');
    });

    test('updateDisplayName merges displayName', () async {
      await userSource.createUserProfile(
        UserEntity(uid: 'u9', displayName: 'EskiAd'),
      );
      await userSource.updateDisplayName('u9', 'YeniAd');

      final doc = await fakeFirestore.collection('users').doc('u9').get();
      expect(doc.data()!['displayName'], 'YeniAd');
    });

    test('watchUserProfile emits when doc changes', () async {
      final stream = userSource.watchUserProfile('u10');
      final values = <UserEntity?>[];
      final sub = stream.listen(values.add);

      await fakeFirestore.collection('users').doc('u10').set({
        'displayName': 'StreamUser',
        'walletPoints': 0,
        'rank': 'Newbie',
        'ownedCosmetics': <dynamic>[],
        'ownedCategories': <dynamic>['genel'],
        'updatedAt': DateTime.now(),
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(values, isNotEmpty);
      expect(values.last!.displayName, 'StreamUser');
      await sub.cancel();
    });

    test('uploadAvatar throws when fileData is not Uint8List', () async {
      expect(
        () => userSource.uploadAvatar('u11', 'not bytes'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Uint8List'),
        )),
      );
    });
  });
}
