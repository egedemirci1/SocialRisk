import 'dart:async';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import 'package:social_risk/features/auth/presentation/profile_screen.dart';
import 'package:social_risk/features/economy/domain/cosmetic_item_entity.dart';
import 'package:social_risk/features/economy/providers/economy_provider.dart';
import '../helpers/fake_economy_controller.dart';
import '../helpers/fake_user_controller.dart';
import '../helpers/fake_user_repository.dart';

void main() {
  group('ProfileScreen', () {
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
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('when user is set shows profile tabs and content', (tester) async {
      final mockUser = MockUser(
        uid: 'profile-uid',
        isAnonymous: false,
        displayName: 'Profil Kullanıcı',
      );
      final fakeProfile = const UserEntity(
        uid: 'profile-uid',
        displayName: 'Profil Kullanıcı',
        walletPoints: 1000,
        ownedCosmetics: [],
      );

      await tester.binding.setSurfaceSize(const Size(800, 1000));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1000)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsWidgets);
      expect(find.text('Eşyalar'), findsWidgets);
      expect(find.text('Performans'), findsWidgets);
      expect(find.text('Profil Kullanıcı'), findsWidgets);
    });

    testWidgets('when user is set no overflow on narrow viewport', (tester) async {
      final mockUser = MockUser(
        uid: 'u',
        isAnonymous: false,
        displayName: 'Uzun İsimli Kullanıcı Adı',
      );
      final fakeProfile = const UserEntity(
        uid: 'u',
        displayName: 'Uzun İsimli Kullanıcı Adı',
        walletPoints: 500,
        ownedCosmetics: [],
      );

      await tester.binding.setSurfaceSize(const Size(320, 568));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(320, 568)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsWidgets);
      expect(find.text('Uzun İsimli Kullanıcı Adı'), findsOneWidget);
    });

    // ---------- Sekme (Tab) geçişleri ----------
    testWidgets('varsayılan sekme Profil: Mağaza butonu ve kullanıcı adı görünür', (tester) async {
      final mockUser = MockUser(uid: 'tu', isAnonymous: false, displayName: 'Tab Kullanıcı');
      final fakeProfile = const UserEntity(uid: 'tu', displayName: 'Tab Kullanıcı', walletPoints: 500, ownedCosmetics: []);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Mağaza'), findsOneWidget);
      expect(find.text('Tab Kullanıcı'), findsWidgets);
      expect(find.byIcon(Icons.confirmation_number_rounded), findsOneWidget);
    });

    testWidgets('Eşyalar sekmesine tıklanınca sekme içeriği değişir', (tester) async {
      final mockUser = MockUser(uid: 'tu', isAnonymous: false, displayName: 'Tab Kullanıcı');
      final fakeProfile = const UserEntity(uid: 'tu', displayName: 'Tab Kullanıcı', walletPoints: 500, ownedCosmetics: []);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Mağaza'), findsOneWidget);
      await tester.tap(find.text('Eşyalar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Henüz bir eşyanız yok'), findsOneWidget);
      expect(find.text('Mağaza'), findsNothing);
    });

    testWidgets('Performans sekmesine tıklanınca İstatistikler ve Bakiye görünür', (tester) async {
      final mockUser = MockUser(uid: 'tu', isAnonymous: false, displayName: 'Tab Kullanıcı');
      final fakeProfile = const UserEntity(uid: 'tu', displayName: 'Tab Kullanıcı', walletPoints: 1200, ownedCosmetics: []);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Performans'));
      await tester.pumpAndSettle();

      expect(find.text('İstatistikler'), findsOneWidget);
      expect(find.text('Bakiye'), findsOneWidget);
      expect(find.text('1200'), findsOneWidget);
      expect(find.byIcon(Icons.monetization_on_rounded), findsOneWidget);
    });

    // ---------- Düzenle butonu etkileşimi ----------
    testWidgets('Profil sekmesinde Düzenle (edit) ikonuna tıklanınca isim güncelleme diyaloğu açılır', (tester) async {
      final mockUser = MockUser(uid: 'eu', isAnonymous: false, displayName: 'Düzenle Kullanıcı');
      final fakeProfile = const UserEntity(uid: 'eu', displayName: 'Düzenle Kullanıcı', walletPoints: 0, ownedCosmetics: []);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Oyuncu Adını Güncelle'), findsOneWidget);
      expect(find.text('Yeni Oyuncu Adı'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('İsim güncelleme diyaloğunda İptal tıklanınca diyalog kapanır', (tester) async {
      final mockUser = MockUser(uid: 'eu', isAnonymous: false, displayName: 'Düzenle Kullanıcı');
      final fakeProfile = const UserEntity(uid: 'eu', displayName: 'Düzenle Kullanıcı', walletPoints: 0, ownedCosmetics: []);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Oyuncu Adını Güncelle'), findsOneWidget);

      await tester.tap(find.text('İPTAL'));
      await tester.pumpAndSettle();
      expect(find.text('Oyuncu Adını Güncelle'), findsNothing);
    });

    testWidgets('İsim güncelleme diyaloğunda geçerli isimle GÜNCELLE tıklanınca diyalog kapanır', (tester) async {
      final mockUser = MockUser(uid: 'eu', isAnonymous: false, displayName: 'Eski');
      final fakeProfile = const UserEntity(uid: 'eu', displayName: 'Eski', walletPoints: 0, ownedCosmetics: []);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'YeniIsim');
      await tester.tap(find.text('GÜNCELLE'));
      await tester.pumpAndSettle();

      expect(find.text('Oyuncu Adını Güncelle'), findsNothing);
      expect(find.text('Profil güncellendi!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    // ---------- Eşyalar sekmesinde liste kaydırma ----------
    testWidgets('Eşyalar sekmesinde birden fazla öğe varken liste kaydırılabilir ve aşağıdaki öğe görünür', (tester) async {
      final mockUser = MockUser(uid: 'su', isAnonymous: false, displayName: 'Scroll Kullanıcı');
      final fakeProfile = UserEntity(
        uid: 'su',
        displayName: 'Scroll Kullanıcı',
        walletPoints: 0,
        ownedCosmetics: List.generate(12, (i) => 'frame_$i'),
      );
      final fakeCosmetics = List<CosmeticItemEntity>.generate(
        12,
        (i) => CosmeticItemEntity(
          id: 'frame_$i',
          name: 'Çerçeve ${i + 1}',
          description: 'Frame $i',
          imageUrl: '🖼️',
          price: 100,
          type: 'frame',
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 600));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(fakeCosmetics)),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 600)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eşyalar'));
      await tester.pumpAndSettle();

      expect(find.text('Çerçeveler'), findsOneWidget);
      expect(find.text('Çerçeve 1'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Çerçeve 12'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Çerçeve 12'), findsOneWidget);
    });

    // ---------- Eşyalar sekmesi: Loading state ----------
    testWidgets('Eşyalar sekmesinde fetchCosmeticsProvider loading iken CircularProgressIndicator görünür', (tester) async {
      final mockUser = MockUser(uid: 'lu', isAnonymous: false, displayName: 'Loading Kullanıcı');
      final fakeProfile = const UserEntity(uid: 'lu', displayName: 'Loading Kullanıcı', walletPoints: 0, ownedCosmetics: []);

      final loadingCompleter = Completer<List<CosmeticItemEntity>>();
      addTearDown(() => loadingCompleter.complete(<CosmeticItemEntity>[]));

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => loadingCompleter.future),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eşyalar'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    // ---------- Eşyalar sekmesi: Error state ----------
    testWidgets('Eşyalar sekmesinde fetchCosmeticsProvider hata verince hata metni görünür', (tester) async {
      final mockUser = MockUser(uid: 'eu', isAnonymous: false, displayName: 'Error Kullanıcı');
      final fakeProfile = const UserEntity(uid: 'eu', displayName: 'Error Kullanıcı', walletPoints: 0, ownedCosmetics: []);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockUser),
            userRepositoryProvider.overrideWithValue(FakeUserRepository(profile: fakeProfile)),
            userControllerProvider.overrideWith(() => FakeUserController()),
            economyControllerProvider.overrideWith(() => FakeEconomyController()),
            fetchCosmeticsProvider.overrideWith((ref) => Future.error(Exception('Yüklenemedi'))),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eşyalar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Hata:'), findsOneWidget);
      expect(find.textContaining('Yüklenemedi'), findsOneWidget);
    });
  });
}
