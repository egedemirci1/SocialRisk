import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/widgets/cards/game_card.dart';

void main() {
  group('GameCard', () {
    testWidgets('renders category and content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GameCard(
                category: 'Cesaret',
                content: 'Test bir görev',
                points: 20,
              ),
            ),
          ),
        ),
      );

      expect(find.text('CESARET'), findsOneWidget);
      expect(find.text('Test bir görev'), findsOneWidget);
      expect(find.text('20 puan'), findsOneWidget);
    });

    testWidgets('shows correct icon for each category', (tester) async {
      final categoryIcons = <String, IconData>{
        'Fiziksel': Icons.fitness_center_rounded,
        'Bilgi': Icons.lightbulb_outline_rounded,
        'Dijital': Icons.phone_android_rounded,
        'İtiraf': Icons.psychology_rounded,
        'Zihinsel': Icons.psychology_alt_rounded,
        'Ahlaki': Icons.balance_rounded,
        'Görsel': Icons.theater_comedy_rounded,
        'Mahrem': Icons.favorite_rounded,
        'Özel': Icons.category_rounded,
      };
      for (final entry in categoryIcons.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: GameCard(
                  category: entry.key,
                  content: 'Görev',
                  points: 10,
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(entry.value), findsOneWidget);
      }
    });

    testWidgets('points gösterilir', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GameCard(
                category: 'Bilgi',
                content: 'Soru sor',
                points: 10,
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
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GameCard(
                category: 'Cesaret',
                content: longContent,
                points: 10,
              ),
            ),
          ),
        ),
      );

      expect(find.text('CESARET'), findsOneWidget);
      expect(find.text(longContent), findsOneWidget);
      await tester.pumpAndSettle();
      // No overflow exception; content is visible inside scrollable.
    });

    testWidgets('content remains findable after scroll', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 800),
                  const GameCard(
                    category: 'Bilgi',
                    content: 'Scroll sonrası görev',
                    points: 20,
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
