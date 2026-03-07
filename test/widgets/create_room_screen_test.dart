import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/auth/domain/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_risk/features/room/presentation/create_room_screen.dart';

/// Minimal fake user for tests — only uid and displayName used by CreateRoomScreen.
class FakeAuthRepositoryWithUser implements AuthRepository {
  FakeAuthRepositoryWithUser(this._user);

  final User? _user;

  @override
  Stream<User?> get authStateChanges => Stream.value(_user);

  @override
  User? get currentUser => _user;

  @override
  Future<UserCredential?> signInAnonymously(String displayName) async =>
      null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}
}

Widget buildCreateRoomScreen() {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepositoryWithUser(null),
      ),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(600, 900)),
        child: const CreateRoomScreen(),
      ),
    ),
  );
}

void main() {
  group('CreateRoomScreen', () {
    testWidgets('renders "Yeni Parti Kur" and "Partiyi Başlat"', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Yeni Parti Kur'), findsOneWidget);
      expect(find.text('Partiyi Başlat'), findsOneWidget);
    });

    testWidgets('shows Oyun Sonu and Oyun Modu sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Oyun Sonu'), findsOneWidget);
      expect(find.text('Oyun Modu'), findsOneWidget);
      expect(find.text('Kategoriler'), findsOneWidget);
    });

    testWidgets('default is Puan mode and shows score slider', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Puan'), findsWidgets);
      expect(find.text('500 Puan'), findsOneWidget);
    });

    testWidgets('tap Tur chip switches to round mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Tur').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('5 Tur'), findsOneWidget);
    });

    testWidgets('tap Ekonomi chip shows Patron Parti', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Ekonomi').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Patron Parti'), findsOneWidget);
    });

    testWidgets('tap Partiyi Başlat with null user does not crash', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 1200));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.scrollUntilVisible(find.text('Partiyi Başlat'), 500);
      await tester.tap(find.text('Partiyi Başlat'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byType(CreateRoomScreen), findsOneWidget);
    });

    testWidgets('has Slider for score in Puan mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(buildCreateRoomScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
