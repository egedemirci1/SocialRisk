import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import 'package:social_risk/shared/widgets/common/report_dialog.dart';
import '../helpers/fake_user_controller.dart';

void main() {
  group('ReportDialog', () {
    testWidgets('opens dialog with title and reason dropdown', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userControllerProvider.overrideWith(() => FakeUserController()),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => ReportDialog.show(
                      ctx,
                      ref,
                      targetUserId: 'u1',
                      targetUserName: 'Test User',
                      targetUserAvatar: '',
                    ),
                    child: const Text('Raporla'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Raporla'));
      await tester.pumpAndSettle();

      expect(find.text('Kullanıcıyı Raporla'), findsOneWidget);
      expect(find.text('Bu kullanıcının profil fotoğrafını raporlamak istediğinize emin misiniz?'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);
      expect(find.text('Raporla'), findsWidgets);
      expect(find.text('Uygunsuz Fotoğraf / Çıplaklık'), findsOneWidget);
    });

    testWidgets('İptal closes dialog without calling reportUser', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userControllerProvider.overrideWith(() => FakeUserController()),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => ReportDialog.show(
                      ctx,
                      ref,
                      targetUserId: 'u1',
                      targetUserName: 'Test',
                      targetUserAvatar: '',
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();

      expect(find.text('Kullanıcıyı Raporla'), findsNothing);
    });

    testWidgets('Raporla tap calls reportUser (no crash with fake)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userControllerProvider.overrideWith(() => FakeUserController()),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => ReportDialog.show(
                      ctx,
                      ref,
                      targetUserId: 'u1',
                      targetUserName: 'Test',
                      targetUserAvatar: '',
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Raporla'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Kullanıcıyı Raporla'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
