import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/economy/data/firebase_economy_source.dart';
import 'package:social_risk/features/economy/domain/economy_exceptions.dart';

void main() {
  group('FirebaseEconomySource', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseEconomySource economySource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      economySource = FirebaseEconomySource(firestore: fakeFirestore);
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
      test('yeterli puanla satın alma başarılı ve puan düşer, kozmetik listeye eklenir',
          () async {
        const uid = 'user1';
        await seedUser(uid: uid, walletPoints: 1000, ownedCosmetics: []);

        await economySource.buyCosmetic(
          uid: uid,
          cosmeticId: 'frame_fire',
          price: 500,
        );

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.exists, isTrue);
        final data = doc.data()!;
        expect(data['walletPoints'], 500);
        expect(
          List<String>.from(data['ownedCosmetics'] ?? []),
          contains('frame_fire'),
        );
      });

      test('puan yetersizse InsufficientBalanceException fırlatır', () async {
        const uid = 'user2';
        await seedUser(uid: uid, walletPoints: 100, ownedCosmetics: []);

        expect(
          () => economySource.buyCosmetic(
            uid: uid,
            cosmeticId: 'frame_fire',
            price: 500,
          ),
          throwsA(isA<InsufficientBalanceException>()),
        );

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['walletPoints'], 100);
        expect(List<String>.from(doc.data()!['ownedCosmetics'] ?? []), isEmpty);
      });

      test('zaten alınmış ürün için AlreadyOwnedCosmeticException fırlatır',
          () async {
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
          throwsA(isA<AlreadyOwnedCosmeticException>()),
        );

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['walletPoints'], 1000);
        expect(
          List<String>.from(doc.data()!['ownedCosmetics'] ?? []),
          ['frame_fire'],
        );
      });

      test('kullanıcı yoksa UserNotFoundException fırlatır', () async {
        expect(
          () => economySource.buyCosmetic(
            uid: 'nonexistent_user',
            cosmeticId: 'frame_fire',
            price: 500,
          ),
          throwsA(isA<UserNotFoundException>()),
        );
      });

      test('satın alınan ürün ownedCosmetics listesine eklenir', () async {
        const uid = 'user4';
        await seedUser(uid: uid, walletPoints: 800, ownedCosmetics: []);

        await economySource.buyCosmetic(
          uid: uid,
          cosmeticId: 'frame_ice',
          price: 500,
        );

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        final owned = List<String>.from(doc.data()!['ownedCosmetics'] ?? []);
        expect(owned, contains('frame_ice'));
        expect(owned.length, 1);
      });
    });

    group('addPointsToWallet (reward / spend)', () {
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
        const uid = 'new_user';
        await economySource.addPointsToWallet(uid: uid, points: 300);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['walletPoints'], 300);
      });
    });

    group('distributeRewards', () {
      test('birden fazla oyuncuya ödül dağıtır', () async {
        await seedUser(uid: 'p1', walletPoints: 0);
        await seedUser(uid: 'p2', walletPoints: 0);

        await economySource.distributeRewards({
          'p1': 100,
          'p2': 200,
        });

        final d1 = await fakeFirestore.collection('users').doc('p1').get();
        final d2 = await fakeFirestore.collection('users').doc('p2').get();
        expect(d1.data()!['walletPoints'], 100);
        expect(d2.data()!['walletPoints'], 200);
      });

      test('boş map ile çağrıldığında hiçbir işlem yapmaz', () async {
        await economySource.distributeRewards({});
        // No throw, no write
      });

      test('sıfır puanlı girdileri atlar', () async {
        await seedUser(uid: 'p3', walletPoints: 50);
        await economySource.distributeRewards({'p3': 0});
        final doc = await fakeFirestore.collection('users').doc('p3').get();
        expect(doc.data()!['walletPoints'], 50);
      });
    });

    group('setActiveFrame / setActiveTitle', () {
      test('setActiveFrame değeri günceller', () async {
        const uid = 'user7';
        await seedUser(uid: uid, walletPoints: 0);

        await economySource.setActiveFrame(uid: uid, cosmeticId: 'frame_fire');

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['activeFrame'], 'frame_fire');
      });

      test('setActiveFrame null ile temizlenir', () async {
        const uid = 'user8';
        await fakeFirestore.collection('users').doc(uid).set({
          'displayName': 'U',
          'walletPoints': 0,
          'activeFrame': 'frame_ice',
          'updatedAt': DateTime.now(),
        });

        await economySource.setActiveFrame(uid: uid, cosmeticId: null);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['activeFrame'], isNull);
      });

      test('setActiveTitle değeri günceller', () async {
        const uid = 'user9';
        await seedUser(uid: uid, walletPoints: 0);

        await economySource.setActiveTitle(uid: uid, cosmeticId: 'title_king');

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['activeTitle'], 'title_king');
      });
    });

    group('fetchCosmetics', () {
      test('sabit kozmetik listesini döner', () async {
        final list = await economySource.fetchCosmetics();
        expect(list, isNotEmpty);
        expect(list.any((e) => e.id == 'frame_fire' && e.type == 'frame'), true);
        expect(list.any((e) => e.id == 'title_legend' && e.type == 'title'), true);
        expect(list.any((e) => e.type == 'category'), true);
      });
    });
  });
}
