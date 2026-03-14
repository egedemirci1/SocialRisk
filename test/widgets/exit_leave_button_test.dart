import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/auth/domain/auth_repository.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/room/providers/room_provider.dart';
import 'package:social_risk/shared/widgets/buttons/exit_room_button.dart';
import 'package:social_risk/shared/widgets/buttons/leave_room_button.dart';
import '../helpers/fake_room_repository.dart';

class _FakeAuthRepoWithUser implements AuthRepository {
  _FakeAuthRepoWithUser(this._user);

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

Widget _buildTestApp(Widget child) {
  final user = MockUser(uid: 'u1', displayName: 'Test');
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuthRepoWithUser(user)),
      roomRepositoryProvider.overrideWithValue(FakeRoomRepository()),
    ],
    child: MaterialApp(
      home: Scaffold(
        appBar: AppBar(actions: [child]),
      ),
    ),
  );
}

void main() {
  group('Exit/Leave buttons countdown', () {
    testWidgets('ExitRoomButton çıkış butonunu 10 saniye kilitli başlatır', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const ExitRoomButton(roomCode: 'R1')));

      await tester.tap(find.byIcon(Icons.exit_to_app_rounded));
      await tester.pumpAndSettle();

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNotNull);
    });

    testWidgets('LeaveRoomButton çıkış butonunu 10 saniye kilitli başlatır', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const LeaveRoomButton(roomCode: 'R1')));

      await tester.tap(find.byIcon(Icons.exit_to_app_rounded));
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(TextButton, 'Sil ve Çık (10)');
      expect(buttonFinder, findsOneWidget);
      expect(tester.widget<TextButton>(buttonFinder).onPressed, isNull);

      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      final enabledFinder = find.widgetWithText(TextButton, 'Sil ve Çık');
      expect(enabledFinder, findsOneWidget);
      expect(tester.widget<TextButton>(enabledFinder).onPressed, isNotNull);
    });
  });
}
