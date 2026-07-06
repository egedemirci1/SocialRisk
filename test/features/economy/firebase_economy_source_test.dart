import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/economy/data/firebase_economy_source.dart';
import '../../helpers/mock_firebase_functions.dart';

void main() {
  group('FirebaseEconomySource', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseFunctions mockFunctions;
    late FirebaseEconomySource economySource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockFunctions = MockFirebaseFunctions();
      economySource = FirebaseEconomySource(
        firestore: fakeFirestore,
        functions: mockFunctions,
      );
    });

    Future<void> seedUser({
      required String uid,
      int walletPoints = 0,
      List<String> ownedCosmetics = const [],
    }) async {
      await fakeFirestore.collection('users').doc(uid).set({
        'displayName': 'TestUser',
        'walletPoints': walletPoints,
        'ownedCosmetics': List<dynamic>.from(ownedCosmetics),
        'updatedAt': DateTime.now(),
      });
    }

    group('buyCosmetic', () {
      test('yeterli puanla satın alma Cloud Function çağrısı yapar', () async {
        const uid = 'user1';
        await seedUser(uid: uid, walletPoints: 1000, ownedCosmetics: []);

        await economySource.buyCosmetic(
          uid: uid,
          cosmeticId: 'frame_fire',
          price: 500,
        );

        expect(mockFunctions.calls.length, 1);
        expect(mockFunctions.calls.first.name, 'buyCosmetic');
        expect(mockFunctions.calls.first.parameters['uid'], uid);
        expect(mockFunctions.calls.first.parameters['cosmeticId'], 'frame_fire');
        expect(mockFunctions.calls.first.parameters['price'], 500);
      });

      test('puan yetersizse Exception fırlatır', () async {
        mockFunctions.handlers['buyCosmetic'] =
            (_) async => throw Exception('Yetersiz bakiye.');

        const uid = 'user2';
        await seedUser(uid: uid, walletPoints: 100, ownedCosmetics: []);

        expect(
          () => economySource.buyCosmetic(
            uid: uid,
            cosmeticId: 'frame_fire',
            price: 500,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('zaten alınmış ürün için Exception fırlatır', () async {
        mockFunctions.handlers['buyCosmetic'] =
            (_) async => throw Exception('Bu eşyaya zaten sahipsiniz.');

        const uid = 'user3';
        await seedUser(
          uid: uid,
          walletPoints: 1000,
          ownedCosmetics: ['frame_fire'],
        );

        expect(
          () => economySource.buyCosmetic(
            uid: uid,
            cosmeticId: 'frame_fire',
            price: 500,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('kullanıcı yoksa Exception fırlatır', () async {
        mockFunctions.handlers['buyCosmetic'] =
            (_) async => throw Exception('Kullanıcı bulunamadı.');

        expect(
          () => economySource.buyCosmetic(
            uid: 'nonexistent_user',
            cosmeticId: 'frame_fire',
            price: 500,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('satın alma çağrısı doğru kozmetik kimliği ile yapılır', () async {
        const uid = 'user4';
        await seedUser(uid: uid, walletPoints: 800, ownedCosmetics: []);

        await economySource.buyCosmetic(
          uid: uid,
          cosmeticId: 'frame_ice',
          price: 500,
        );

        expect(mockFunctions.calls.single.name, 'buyCosmetic');
        expect(mockFunctions.calls.single.parameters['cosmeticId'], 'frame_ice');
      });
    });

    group('addPointsToWallet', () {
      test('puan ekleme (reward) mevcut bakiyeye ekler', () async {
        const uid = 'user5';
        await seedUser(uid: uid, walletPoints: 200);

        await economySource.addPointsToWallet(uid: uid, points: 150);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['walletPoints'], 350);
      });

      test('negatif puan (spend) bakiyeden düşer', () async {
        const uid = 'user6';
        await seedUser(uid: uid, walletPoints: 500);

        await economySource.addPointsToWallet(uid: uid, points: -100);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['walletPoints'], 400);
      });

      test('doc yoksa merge ile oluşturup puan yazar', () async {
        const uid = 'user7';

        await economySource.addPointsToWallet(uid: uid, points: 50);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['walletPoints'], 50);
      });
    });

    group('setActiveFrame / setActiveTitle', () {
      test('setActiveFrame değeri günceller', () async {
        const uid = 'user8';
        await seedUser(uid: uid);

        await economySource.setActiveFrame(uid: uid, cosmeticId: 'frame_fire');

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['activeFrame'], 'frame_fire');
      });

      test('setActiveFrame null ile temizlenir', () async {
        const uid = 'user9';
        await seedUser(uid: uid);
        await fakeFirestore.collection('users').doc(uid).update({
          'activeFrame': 'frame_fire',
        });

        await economySource.setActiveFrame(uid: uid, cosmeticId: null);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['activeFrame'], isNull);
      });

      test('setActiveTitle değeri günceller', () async {
        const uid = 'user10';
        await seedUser(uid: uid);

        await economySource.setActiveTitle(uid: uid, cosmeticId: 'title_king');

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['activeTitle'], 'title_king');
      });
    });

    group('fetchCosmetics', () {
      test('sabit kozmetik listesini döner', () async {
        final items = await economySource.fetchCosmetics();
        expect(items, isNotEmpty);
        expect(items.any((item) => item.id == 'frame_fire'), isTrue);
      });
    });

    group('distributeRewards', () {
      test('Cloud Function çağrısı yapar', () async {
        await economySource.distributeRewards({'p1': 100, 'p2': 50});

        expect(mockFunctions.calls.length, 1);
        expect(mockFunctions.calls.first.name, 'distributeRewards');
        expect(mockFunctions.calls.first.parameters['playerRewards'], {
          'p1': 100,
          'p2': 50,
        });
      });

      test('boş harita için erken döner', () async {
        await economySource.distributeRewards({});

        expect(mockFunctions.calls, isEmpty);
      });
    });
  });
}
