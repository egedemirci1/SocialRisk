import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/core/constants/category_constants.dart';
import 'package:social_risk/features/auth/domain/auth_repository.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/room/presentation/create_room_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/widget_test_app.dart';

class FakeAuthRepositoryWithUser implements AuthRepository {
  FakeAuthRepositoryWithUser(this._user);

  final User? _user;

  @override
  Stream<User?> get authStateChanges => Stream.value(_user);

  @override
  User? get currentUser => _user;

  @override
  Future<UserCredential?> signInAnonymously(String displayName) async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}
}

Widget buildCreateRoomScreen() {
  return wrapWithLocalizedApp(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepositoryWithUser(null),
      ),
    ],
    size: const Size(600, 900),
    child: const CreateRoomScreen(),
  );
}

void main() {
  group('CreateRoomScreen', () {
    testWidgets('renders title and start button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Yeni Parti Kur'), findsOneWidget);
      expect(find.text('Partiyi Başlat'), findsOneWidget);
    });

    testWidgets('shows end condition and game mode sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Oyun Sonu'), findsOneWidget);
      expect(find.text('Oyun Modu'), findsOneWidget);
      expect(find.text('Kategoriler'), findsOneWidget);
    });

    testWidgets('default is round mode and shows round count', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Tur'), findsWidgets);
      expect(find.text('10 tur'), findsOneWidget);
    });

    testWidgets('tap Puan chip switches to score mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Puan').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('250 puan'), findsOneWidget);
    });

    testWidgets('tap Ekonomi chip shows economy mode title', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Ekonomi').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Patron Parti'), findsOneWidget);
    });

    testWidgets('tap start with null user does not crash', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 1200));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.scrollUntilVisible(find.text('Partiyi Başlat'), 500);
      await tester.tap(find.text('Partiyi Başlat'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byType(CreateRoomScreen), findsOneWidget);
    });

    testWidgets('has Slider in Puan mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Puan').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
