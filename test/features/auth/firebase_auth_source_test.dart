import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/auth/data/firebase_auth_source.dart';
import 'package:social_risk/features/auth/data/firebase_user_source.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import '../../helpers/mock_firebase_functions.dart';

void main() {
  group('FirebaseAuthSource', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseStorage mockStorage;
    late FirebaseUserSource userSource;
    late MockFirebaseFunctions mockFunctions;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
      mockStorage = MockFirebaseStorage();
      userSource = FirebaseUserSource(firestore: fakeFirestore, storage: mockStorage);
      mockFunctions = MockFirebaseFunctions(
        handlers: {
          'deleteOwnUserData': (params) async {
            final uid = (params as Map)['uid'] as String;
            await fakeFirestore.collection('users').doc(uid).delete();
            return {'deleted': true};
          },
        },
      );
    });

    FirebaseAuthSource buildSource() => FirebaseAuthSource(
          auth: mockAuth,
          userRepository: userSource,
          functions: mockFunctions,
        );

    test('signInAnonymously creates user and writes profile to Firestore', () async {
      final source = buildSource();
      final credential = await source.signInAnonymously('Oyuncu1');

      expect(credential, isNotNull);
      final uid = credential!.user!.uid;
      expect(uid, isNotEmpty);

      final doc = await fakeFirestore.collection('users').doc(uid).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['displayName'], 'Oyuncu1');
    });

    test('when already anonymous, updateDisplayName and upsert profile', () async {
      final source = buildSource();
      await source.signInAnonymously('First');
      final uid = mockAuth.currentUser!.uid;

      await source.signInAnonymously('YeniIsim');

      final doc = await fakeFirestore.collection('users').doc(uid).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['displayName'], 'YeniIsim');
    });

    test('signOut deletes anonymous user doc and avatar from UserSource', () async {
      final mockUser = MockUser(uid: 'anon_3', isAnonymous: true);
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      userSource = FirebaseUserSource(firestore: fakeFirestore, storage: mockStorage);

      await userSource.createUserProfile(
        UserEntity(uid: 'anon_3', displayName: 'Silinecek'),
      );
      var doc = await fakeFirestore.collection('users').doc('anon_3').get();
      expect(doc.exists, isTrue);

      final source = FirebaseAuthSource(
        auth: mockAuth,
        userRepository: userSource,
        functions: MockFirebaseFunctions(
          handlers: {
            'deleteOwnUserData': (params) async {
              await fakeFirestore.collection('users').doc('anon_3').delete();
              return {'deleted': true};
            },
          },
        ),
      );
      await source.signOut();

      doc = await fakeFirestore.collection('users').doc('anon_3').get();
      expect(doc.exists, isFalse);
      expect(mockFunctions.calls, isEmpty);
    });

    test('signOut when not anonymous only signs out', () async {
      final mockUser = MockUser(uid: 'google_1', isAnonymous: false);
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);

      final source = buildSource();
      await source.signOut();

      expect(mockAuth.currentUser, isNull);
      final doc = await fakeFirestore.collection('users').doc('google_1').get();
      expect(doc.exists, isFalse);
    });

    test('currentUser returns auth currentUser', () {
      final mockUser = MockUser(uid: 'u1', isAnonymous: true);
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);

      final source = buildSource();
      expect(source.currentUser, mockUser);
    });

    test('authStateChanges delegates to auth', () {
      final source = buildSource();
      expect(source.authStateChanges, isNotNull);
    });

    test('updateDisplayName calls auth currentUser updateDisplayName', () async {
      final mockUser = MockUser(uid: 'u2', isAnonymous: true, displayName: 'Eski');
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);

      final source = buildSource();
      await source.updateDisplayName('YeniAd');

      expect(mockAuth.currentUser!.displayName, 'YeniAd');
    });
  });
}
