import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/widgets/common/responsive_wrapper.dart';

void main() {
  group('ResponsiveWrapper', () {
    testWidgets('renders Center and ConstrainedBox with child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWrapper(
            child: const Text('Child'),
          ),
        ),
      );
      expect(find.byType(Center), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('respects maxWidth via ConstrainedBox', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWrapper(
            maxWidth: 400,
            child: const SizedBox(width: 500, height: 100),
          ),
        ),
      );
      final constrained = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where((c) => c.constraints.maxWidth == 400)
          .first;
      expect(constrained.constraints.maxWidth, 400);
    });

    testWidgets('isTablet returns true when shortestSide >= 600', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 1200)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final isTablet = ResponsiveWrapper.isTablet(context);
                return Text('tablet:$isTablet');
              },
            ),
          ),
        ),
      );
      expect(find.text('tablet:true'), findsOneWidget);
    });

    testWidgets('isTablet returns false when shortestSide < 600', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final isTablet = ResponsiveWrapper.isTablet(context);
                return Text('tablet:$isTablet');
              },
            ),
          ),
        ),
      );
      expect(find.text('tablet:false'), findsOneWidget);
    });

    testWidgets('gridColumns returns 1 for narrow width', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final cols = ResponsiveWrapper.gridColumns(context);
                return Text('cols:$cols');
              },
            ),
          ),
        ),
      );
      expect(find.text('cols:1'), findsOneWidget);
    });

    testWidgets('gridColumns returns 2 for medium width', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(700, 800)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final cols = ResponsiveWrapper.gridColumns(context);
                return Text('cols:$cols');
              },
            ),
          ),
        ),
      );
      expect(find.text('cols:2'), findsOneWidget);
    });

    testWidgets('gridColumns returns 3 for wide width', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1000, 800)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final cols = ResponsiveWrapper.gridColumns(context);
                return Text('cols:$cols');
              },
            ),
          ),
        ),
      );
      expect(find.text('cols:3'), findsOneWidget);
    });
  });
}
