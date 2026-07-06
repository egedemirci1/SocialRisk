import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/game/presentation/widgets/turn_counter_badge.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('TurnCounterBadge - Widget Tests', () {
    
    // Yardımcı foksiyon: Test edilecek widget'ı MaterialApp içinde sarmala
    Widget createWidgetUnderTest({
      required int currentRound,
      required EndConditionType endConditionType,
      required int endConditionValue,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TurnCounterBadge(
            currentRound: currentRound,
            endConditionType: endConditionType,
            endConditionValue: endConditionValue,
          ),
        ),
      );
    }

    testWidgets('Rounds bitiş koşulunda doğru metni göstermeli', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        currentRound: 3,
        endConditionType: EndConditionType.rounds,
        endConditionValue: 10,
      ));

      // Act
      await tester.pump();

      // Assert
      expect(find.text('3 / 10 Tur'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Score bitiş koşulunda doğru metni göstermeli', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        currentRound: 2,
        endConditionType: EndConditionType.score,
        endConditionValue: 50,
      ));

      // Act
      await tester.pump();

      // Assert
      expect(find.text('2. Tur • 50 P'), findsOneWidget);
    });
  });
}
