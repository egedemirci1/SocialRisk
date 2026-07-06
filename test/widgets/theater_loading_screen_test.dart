import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/widgets/common/social_risk_logo.dart';
import 'package:social_risk/shared/widgets/common/theater_loading_screen.dart';

import '../helpers/widget_test_app.dart';

void main() {
  group('TheaterLoadingScreen', () {
    testWidgets('shows message and progress indicator', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizedApp(
          child: const TheaterLoadingScreen(message: 'Parti Hazırlanıyor...'),
        ),
      );

      expect(find.text('Parti Hazırlanıyor...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(SocialRiskLogo), findsOneWidget);
    });

    testWidgets('shows custom message', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizedApp(
          child: const TheaterLoadingScreen(message: 'Yükleniyor...'),
        ),
      );
      expect(find.text('Yükleniyor...'), findsOneWidget);
    });

    testWidgets('determinate progress shows value', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizedApp(
          child: const TheaterLoadingScreen(
            message: 'Yükleniyor...',
            progress: 0.5,
          ),
        ),
      );
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });

    testWidgets('indeterminate progress has null value', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizedApp(
          child: const TheaterLoadingScreen(message: 'Parti Hazırlanıyor...'),
        ),
      );
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, isNull);
    });
  });
}
