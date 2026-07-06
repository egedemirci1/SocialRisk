import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/constants/app_colors.dart';
import 'package:social_risk/shared/widgets/buttons/stage_button.dart';

import '../helpers/widget_test_app.dart';

void main() {
  testWidgets('disabled StageButton does not call onPressed', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      wrapWithLocalizedApp(
        child: StageButton(
          label: 'Katıl',
          icon: Icons.login_rounded,
          backgroundColor: AppColors.primary,
          textColor: AppColors.background,
          borderColor: Colors.transparent,
          onPressed: null,
        ),
      ),
    );

    await tester.tap(find.byType(StageButton));
    await tester.pump();

    expect(tapped, isFalse);
  });

  testWidgets('enabled StageButton calls onPressed', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      wrapWithLocalizedApp(
        child: StageButton(
          label: 'Katıl',
          icon: Icons.login_rounded,
          backgroundColor: AppColors.primary,
          textColor: AppColors.background,
          borderColor: Colors.transparent,
          onPressed: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(StageButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
