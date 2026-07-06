import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/widgets/common/async_error_view.dart';
import 'package:social_risk/shared/widgets/buttons/primary_button.dart';

import '../helpers/widget_test_app.dart';

void main() {
  testWidgets('AsyncErrorView shows retry and calls onRetry', (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      wrapWithLocalizedApp(
        child: AsyncErrorView(
          message: 'Veriler yüklenemedi',
          detail: 'Network error',
          onRetry: () => retryCount++,
        ),
      ),
    );

    expect(find.text('Veriler yüklenemedi'), findsOneWidget);
    expect(find.text('Network error'), findsOneWidget);
    expect(find.byType(PrimaryButton), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(retryCount, 1);
  });

  testWidgets('AsyncErrorView compact mode shows refresh icon', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      wrapWithLocalizedApp(
        child: AsyncErrorView(
          compact: true,
          message: 'Bakiye yüklenemedi',
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();

    expect(retried, isTrue);
  });

  testWidgets('AsyncErrorView secondary action is tappable', (tester) async {
    var secondaryTapped = false;

    await tester.pumpWidget(
      wrapWithLocalizedApp(
        child: AsyncErrorView(
          message: 'Veriler yüklenemedi',
          secondaryLabel: 'Ana menüye dön',
          onSecondary: () => secondaryTapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Ana menüye dön'));
    await tester.pump();

    expect(secondaryTapped, isTrue);
  });
}
