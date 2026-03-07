import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import 'package:social_risk/features/economy/domain/cosmetic_item_entity.dart';
import 'package:social_risk/features/economy/providers/economy_provider.dart';
import 'package:social_risk/features/store/presentation/store_screen.dart';
import '../helpers/fake_economy_controller.dart';
import '../helpers/fake_user_repository.dart';

/// buyCosmetic çağrıldığında "Yetersiz bakiye" fırlatan controller.
class ThrowInsufficientBalanceEconomyController extends EconomyController {
  @override
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  }) async {
    throw Exception('Yetersiz bakiye');
  }
}

void main() {
  group('StoreScreen', () {
    testWidgets('when user is null shows loading indicator', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('when user is set shows Mağaza and tabs', (tester) async {
      final mockUser = MockUser(
        uid: 'test-uid',
        isAnonymous: false,
        displayName: 'Test User',
      );
      final fakeUserRepo = FakeUserRepository();
      final fakeCosmetics = <CosmeticItemEntity>[
        const CosmeticItemEntity(
          id: 'title_king',
          name: 'Kral',
          description: 'Unvan',
          imageUrl: '👑',
          price: 1000,
          type: 'title',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(fakeUserRepo),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(fakeCosmetics)),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Mağaza'), findsOneWidget);
      expect(find.text('Ünvanlar'), findsWidgets);
      expect(find.text('Çerçeveler'), findsWidgets);
      expect(find.text('Senaryolar'), findsWidgets);
      expect(find.text('Kral'), findsOneWidget);
    });

    testWidgets('shows wallet points from user profile', (tester) async {
      final mockUser = MockUser(uid: 'test-uid', isAnonymous: false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(
              profile: const UserEntity(
                uid: 'test-uid',
                displayName: 'Test',
                walletPoints: 2500,
                ownedCosmetics: [],
              ),
            )),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('2500'), findsOneWidget);
    });

    testWidgets('back button is present', (tester) async {
      final mockUser = MockUser(uid: 'test-uid', isAnonymous: false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back_ios_rounded), findsOneWidget);
    });

    // ---------- Başarılı satın alma ----------
    testWidgets('1000 puanlı kullanıcı 500 puanlık Kral ünvanını alınca buyCosmetic doğru parametreyle çağrılır ve Gardırobunuzda toast çıkar', (tester) async {
      const uid = 'store-buy-uid';
      final mockUser = MockUser(uid: uid, isAnonymous: false, displayName: 'Buyer');
      final fakeProfile = const UserEntity(
        uid: uid,
        displayName: 'Buyer',
        walletPoints: 1000,
        ownedCosmetics: [],
      );
      final spyEconomy = SpyEconomyController();
      const kral = CosmeticItemEntity(
        id: 'title_king',
        name: 'Kral',
        description: 'Tüm alanların hükümdarı.',
        imageUrl: '👑',
        price: 500,
        type: 'title',
      );
      final cosmetics = [kral];

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(cosmetics)),
            economyControllerProvider.overrideWith(() => spyEconomy),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('500'));
      await tester.pumpAndSettle();

      expect(spyEconomy.buyCosmeticCalls.length, 1);
      expect(spyEconomy.buyCosmeticCalls[0].uid, uid);
      expect(spyEconomy.buyCosmeticCalls[0].cosmeticId, 'title_king');
      expect(spyEconomy.buyCosmeticCalls[0].price, 500);
      expect(find.textContaining('gardırobunuzda'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    // ---------- Yetersiz bakiye ----------
    testWidgets('buyCosmetic Yetersiz bakiye fırlatınca ekranda Yetersiz bakiye mesajı görünür', (tester) async {
      const uid = 'store-poor-uid';
      final mockUser = MockUser(uid: uid, isAnonymous: false);
      final fakeProfile = const UserEntity(
        uid: uid,
        displayName: 'Poor',
        walletPoints: 100,
        ownedCosmetics: [],
      );
      const kral = CosmeticItemEntity(
        id: 'title_king',
        name: 'Kral',
        description: 'Unvan',
        imageUrl: '👑',
        price: 500,
        type: 'title',
      );

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value([kral])),
            economyControllerProvider.overrideWith(() => ThrowInsufficientBalanceEconomyController()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('500'));
      await tester.pumpAndSettle();

      expect(find.text('Yetersiz bakiye'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    // ---------- Tab geçişleri: Çerçeveler ----------
    testWidgets('Çerçeveler sekmesine tıklanınca sadece çerçeve tipi ürünler listelenir', (tester) async {
      final mockUser = MockUser(uid: 'tab-uid', isAnonymous: false);
      final cosmetics = [
        const CosmeticItemEntity(
          id: 'title_king',
          name: 'Kral',
          description: 'Unvan',
          imageUrl: '👑',
          price: 1000,
          type: 'title',
        ),
        const CosmeticItemEntity(
          id: 'frame_fire',
          name: 'Ateş Çerçevesi',
          description: 'Ateş efekti',
          imageUrl: '🔥',
          price: 500,
          type: 'frame',
        ),
      ];

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(cosmetics)),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Kral'), findsOneWidget);
      await tester.tap(find.text('Çerçeveler'));
      await tester.pumpAndSettle();

      expect(find.text('Ateş Çerçevesi'), findsOneWidget);
      expect(find.text('Profil fotoğrafınızın etrafında parlayan özel efektler.'), findsOneWidget);
      expect(find.text('Kral'), findsNothing);
    });

    // ---------- Tab geçişleri: Senaryolar ----------
    testWidgets('Senaryolar sekmesine tıklanınca sabit senaryo paketleri (Kapalı Gişe +18 vb.) görünür', (tester) async {
      final mockUser = MockUser(uid: 'scenario-uid', isAnonymous: false);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Senaryolar'));
      await tester.pumpAndSettle();

      expect(find.text('Kapalı Gişe (+18)'), findsOneWidget);
      expect(find.text('Özel Senaryolar'), findsOneWidget);
    });

    // ---------- Cüzdan + butonu ----------
    testWidgets('Cüzdan yanındaki + butonuna basılınca addPointsToWallet 500 puan ile çağrılır', (tester) async {
      const uid = 'wallet-add-uid';
      final mockUser = MockUser(uid: uid, isAnonymous: false);
      final fakeProfile = const UserEntity(
        uid: uid,
        displayName: 'User',
        walletPoints: 100,
        ownedCosmetics: [],
      );
      final spyEconomy = SpyEconomyController();

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            economyControllerProvider.overrideWith(() => spyEconomy),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(spyEconomy.addPointsToWalletCalls.length, 1);
      expect(spyEconomy.addPointsToWalletCalls[0].uid, uid);
      expect(spyEconomy.addPointsToWalletCalls[0].points, 500);
      await tester.pump(const Duration(seconds: 4));
    });

    // ---------- Sahiplik durumu ----------
    testWidgets('ownedCosmetics listesindeki ürün için SAHİP gösterilir ve fiyat görünmez', (tester) async {
      const uid = 'owned-uid';
      final mockUser = MockUser(uid: uid, isAnonymous: false);
      const kral = CosmeticItemEntity(
        id: 'title_king',
        name: 'Kral',
        description: 'Unvan',
        imageUrl: '👑',
        price: 500,
        type: 'title',
      );
      final fakeProfile = const UserEntity(
        uid: uid,
        displayName: 'Owner',
        walletPoints: 1000,
        ownedCosmetics: ['title_king'],
      );

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value([kral])),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const StoreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Kral'), findsOneWidget);
      expect(find.text('SAHİP'), findsOneWidget);
      expect(find.text('500'), findsNothing);
    });
  });
}
