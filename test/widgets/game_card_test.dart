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
                multiplier: 2,
              ),
            ),
          ),
        ),
      );

      expect(find.text('CESARET'), findsOneWidget);
      expect(find.text('Test bir görev'), findsOneWidget);
      expect(find.text('2x Puan'), findsOneWidget);
    });

    testWidgets('shows correct icon for each category', (tester) async {
      for (final entry in <String, IconData>{
        'Cesaret': Icons.local_fire_department_rounded,
        'İtiraf': Icons.psychology_rounded,
        'Taklit': Icons.theater_comedy_rounded,
        'Sosyal Medya': Icons.phone_android_rounded,
        'Fiziksel': Icons.fitness_center_rounded,
        'Bilgi': Icons.lightbulb_outline_rounded,
      }.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: GameCard(
                  category: entry.key,
                  content: 'Görev',
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(entry.value), findsOneWidget);
      }
    });

    testWidgets('default multiplier is 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GameCard(
                category: 'Bilgi',
                content: 'Soru sor',
              ),
            ),
          ),
        ),
      );

      expect(find.text('1x Puan'), findsOneWidget);
    });
  });
}
