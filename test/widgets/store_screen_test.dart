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
  });
}
