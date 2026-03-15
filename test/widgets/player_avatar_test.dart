import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_risk/core/constants/app_colors.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import 'package:social_risk/shared/widgets/common/player_avatar.dart';
import '../helpers/fake_user_repository.dart';
import '../helpers/mock_image_http.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://test'));
  });

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

    // --- Avatar URL senaryoları ---

    testWidgets('avatarUrl verildiğinde CircleAvatar backgroundImage kullanır', (tester) async {
      const url = 'https://example.com/avatar.png';
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userRepositoryProvider.overrideWithValue(FakeUserRepository()),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: const PlayerAvatar(
                  displayName: 'Ali',
                  avatarUrl: 'https://example.com/avatar.png',
                  radius: 24,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(circleAvatar.backgroundImage, isNotNull);
        expect(circleAvatar.backgroundImage, isA<NetworkImage>());
        expect((circleAvatar.backgroundImage! as NetworkImage).url, url);
        expect(find.text('A'), findsNothing);
      }, createHttpClient: createMockImageHttpClient);
    });

    testWidgets('uid ile gelen profilde avatarUrl ve activeFrame varsa NetworkImage ve CustomPaint kullanılır', (tester) async {
      const url = 'https://example.com/photo.jpg';
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userRepositoryProvider.overrideWithValue(FakeUserRepository(
                profile: UserEntity(
                  uid: 'u1',
                  displayName: 'Test',
                  avatarUrl: url,
                  activeFrame: 'frame_ice',
                  ownedCosmetics: const [],
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
        final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(circleAvatar.backgroundImage, isNotNull);
        expect(circleAvatar.backgroundImage, isA<NetworkImage>());
        expect((circleAvatar.backgroundImage! as NetworkImage).url, url);
      }, createHttpClient: createMockImageHttpClient);
    });

    testWidgets('avatarUrl boş string gelirse baş harfe düşer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const PlayerAvatar(
                displayName: 'Ali',
                avatarUrl: '',
                radius: 24,
              ),
            ),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
    });

    // --- Tüm çerçeve varyasyonları (renk eşleme) ---

    const frameIdsAndExpectedColors = [
      ('frame_fire', AppColors.fire),
      ('frame_ice', AppColors.ice),
      ('frame_flower', Colors.pinkAccent),
      ('frame_shield', Colors.indigoAccent),
      ('frame_ivy', Colors.green),
      ('frame_neon', Colors.cyanAccent),
      ('frame_stars', Color(0xFFD4AF37)),
      ('frame_lightning', Colors.lightBlueAccent),
    ];

    for (final entry in frameIdsAndExpectedColors) {
      final frameId = entry.$1;
      final expectedColor = entry.$2;
      testWidgets('frameId $frameId doğru renk ile BoxShadow ve CustomPaint üretir', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userRepositoryProvider.overrideWithValue(FakeUserRepository()),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: PlayerAvatar(
                  displayName: 'X',
                  frameId: frameId,
                  radius: 24,
                  score: 0,
                ),
              ),
            ),
          ),
        );
        final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
        final decoration = decoratedBox.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, 1);
        final shadowColor = decoration.boxShadow!.first.color;
        // withValues(alpha: 0.5) -> 0.5 * 255 ≈ 128
        expect(shadowColor.alpha, 128);
        expect(shadowColor.red, expectedColor.red);
        expect(shadowColor.green, expectedColor.green);
        expect(shadowColor.blue, expectedColor.blue);
        expect(find.byType(CustomPaint), findsWidgets);
      });
    }

    testWidgets('bilinmeyen frameId AppColors.primary kullanır', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const PlayerAvatar(
                displayName: 'X',
                frameId: 'frame_unknown',
                radius: 24,
                score: 0,
              ),
            ),
          ),
        ),
      );
      final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.boxShadow!.first.color.red, AppColors.primary.red);
      expect(decoration.boxShadow!.first.color.green, AppColors.primary.green);
      expect(decoration.boxShadow!.first.color.blue, AppColors.primary.blue);
    });

    // --- Puan bazlı görsel değişimler ---

    testWidgets('skor 500 iken _borderColor ice ve border width 2.5', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const PlayerAvatar(
                displayName: 'X',
                radius: 24,
                score: 500,
                showEffect: false,
              ),
            ),
          ),
        ),
      );
      final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = decoratedBox.decoration as BoxDecoration;
      final border = decoration.border;
      expect(border, isNotNull);
      expect(border!.top.color, AppColors.ice);
      expect(border.top.width, 2.5);
    });

    testWidgets('skor 1500 iken DecoratedBox içinde BoxShadow (glow) oluşur', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const PlayerAvatar(
                displayName: 'X',
                radius: 24,
                score: 1500,
                showEffect: false,
              ),
            ),
          ),
        ),
      );
      final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow!.first.blurRadius, 12);
      expect(decoration.boxShadow!.first.spreadRadius, 1);
    });

    // --- Aura ve glow sınırları ---

    testWidgets('currentFrameId null değilken aura border ve CustomFramePainter çizilir', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const PlayerAvatar(
                displayName: 'X',
                frameId: 'frame_neon',
                radius: 24,
                score: 0,
              ),
            ),
          ),
        ),
      );
      // Frame varsa 2 Positioned (aura border ve CustomFramePainter), effect için 1 Positioned daha olabilir
      expect(find.byType(Positioned), findsAtLeastNWidgets(2));
      expect(find.byType(CustomPaint), findsWidgets);
      final stackFinder = find.descendant(
        of: find.byType(PlayerAvatar),
        matching: find.byType(Stack),
      );
      expect(stackFinder, findsOneWidget);
      final stack = tester.widget<Stack>(stackFinder);
      var foundAuraContainer = false;
      for (final w in stack.children) {
        if (w is Positioned) {
          final child = w.child;
          if (child is IgnorePointer && child.child is Container) {
            final container = child.child as Container;
            final dec = container.decoration;
            if (dec is BoxDecoration && dec.border != null) {
              foundAuraContainer = true;
              break;
            }
          }
        }
      }
      expect(foundAuraContainer, isTrue);
    });
  });
}
