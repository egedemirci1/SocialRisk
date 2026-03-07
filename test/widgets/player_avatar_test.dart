import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import 'package:social_risk/shared/widgets/common/player_avatar.dart';
import '../helpers/fake_user_repository.dart';

void main() {
  group('PlayerAvatar', () {
    testWidgets('shows first letter when no avatarUrl', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const PlayerAvatar(
                displayName: 'Ali',
                radius: 24,
              ),
            ),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('shows question mark when displayName empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAvatar(displayName: '', radius: 24),
          ),
        ),
      );
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('score effect: 0 shows no emoji', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAvatar(displayName: 'X', score: 0, radius: 24),
          ),
        ),
      );
      expect(find.text('🔥'), findsNothing);
      expect(find.text('✨'), findsNothing);
      expect(find.text('❄️'), findsNothing);
    });

    testWidgets('score effect: 500+ shows ice emoji', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAvatar(displayName: 'X', score: 500, radius: 24, showEffect: true),
          ),
        ),
      );
      expect(find.text('❄️'), findsOneWidget);
    });

    testWidgets('score effect: 1500+ shows sparkle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAvatar(displayName: 'X', score: 1500, radius: 24, showEffect: true),
          ),
        ),
      );
      expect(find.text('✨'), findsOneWidget);
    });

    testWidgets('score effect: 3000+ shows fire', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAvatar(displayName: 'X', score: 3000, radius: 24, showEffect: true),
          ),
        ),
      );
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('with uid uses profile frame from watchUserProfile', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(FakeUserRepository(
              profile: const UserEntity(
                uid: 'u1',
                displayName: 'Test',
                activeFrame: 'frame_fire',
                ownedCosmetics: [],
              ),
            )),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const PlayerAvatar(
                displayName: 'Test',
                uid: 'u1',
                radius: 24,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
