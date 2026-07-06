import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/constants/category_constants.dart';
import 'package:social_risk/shared/widgets/cards/game_card.dart';

import '../helpers/widget_test_app.dart';

void main() {
  group('GameCard', () {
    testWidgets('renders category and content', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizedApp(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 320,
                child: GameCard(
                  category: 'Fiziksel',
                  content: 'Test bir görev',
                  points: 20,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('FIZIKSEL'), findsOneWidget);
      expect(find.text('Test bir görev'), findsOneWidget);
      expect(find.text('20 puan'), findsOneWidget);
    });

    testWidgets('shows correct icon for each category', (tester) async {
      for (final categoryDef in CategoryConstants.all) {
        await tester.pumpWidget(
          wrapWithLocalizedApp(
            child: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  height: 320,
                  child: GameCard(
                    category: categoryDef.id,
                    content: 'Görev',
                    points: 10,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(categoryDef.icon), findsOneWidget);
      }
    });

    testWidgets('points gösterilir', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizedApp(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 320,
                child: GameCard(
                  category: 'Bilgi',
                  content: 'Soru sor',
                  points: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('10 puan'), findsOneWidget);
    });

    testWidgets('long content does not overflow when inside scrollable', (tester) async {
      const longContent = 'Bu çok uzun bir görev metnidir. '
          'Birkaç cümle ekleyerek overflow olup olmadığını kontrol ediyoruz. '
          'Kart scroll edilebilir bir parent içinde olmalı ki taşma olmasın. '
          'Flutter test ortamında bunu doğruluyoruz.';
      await tester.pumpWidget(
        wrapWithLocalizedApp(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 320,
                child: GameCard(
                  category: 'Fiziksel',
                  content: longContent,
                  points: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('FIZIKSEL'), findsOneWidget);
      expect(find.text(longContent), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('content remains findable after scroll', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizedApp(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 800),
                  const SizedBox(
                    height: 320,
                    child: GameCard(
                      category: 'Bilgi',
                      content: 'Scroll sonrası görev',
                      points: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Scroll sonrası görev'), findsOneWidget);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('Scroll sonrası görev'), findsOneWidget);
    });
  });
}
