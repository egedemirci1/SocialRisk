import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/widgets/common/theater_loading_screen.dart';

void main() {
  group('TheaterLoadingScreen', () {
    testWidgets('shows default message and progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TheaterLoadingScreen(),
        ),
      );
      expect(find.text('Parti Hazırlanıyor...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.celebration_rounded), findsOneWidget);
    });

    testWidgets('shows custom message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TheaterLoadingScreen(message: 'Yükleniyor...'),
        ),
      );
      expect(find.text('Yükleniyor...'), findsOneWidget);
    });

    testWidgets('determinate progress shows value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TheaterLoadingScreen(progress: 0.5),
        ),
      );
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });

    testWidgets('indeterminate progress has null value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TheaterLoadingScreen(),
        ),
      );
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, isNull);
    });
  });
}
