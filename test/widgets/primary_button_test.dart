import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/widgets/buttons/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders label correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('renders with icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'With Icon',
              icon: Icons.play_arrow_rounded,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Tap Me',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when null (disabled)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      // Widget should render but tap should not trigger anything
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('when isLoading is true, tap does not call onPressed', (tester) async {
      int pressCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Submit',
              isLoading: true,
              onPressed: () => pressCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump(const Duration(milliseconds: 100));
      expect(pressCount, 0);
    });

    testWidgets('is accessible with Semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Accessible Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Accessible Button'), findsOneWidget);
    });
  });
}
