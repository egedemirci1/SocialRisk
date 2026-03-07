import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/widgets/common/custom_frame_painter.dart';

void main() {
  group('CustomFramePainter', () {
    const frameIds = [
      'frame_fire',
      'frame_ice',
      'frame_flower',
      'frame_shield',
      'frame_ivy',
      'frame_neon',
      'frame_stars',
      'frame_lightning',
    ];

    for (final frameId in frameIds) {
      testWidgets('paints without error for $frameId', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                painter: CustomFramePainter(frameId: frameId, radius: 40),
                size: const Size(100, 100),
              ),
            ),
          ),
        );
        expect(find.byType(CustomPaint), findsWidgets);
      });
    }

    testWidgets('shouldRepaint returns true when frameId or radius changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: CustomFramePainter(frameId: 'frame_fire', radius: 40),
              size: const Size(100, 100),
            ),
          ),
        ),
      );
      final painter = CustomFramePainter(frameId: 'frame_fire', radius: 40);
      final otherFrame = CustomFramePainter(frameId: 'frame_ice', radius: 40);
      final otherRadius = CustomFramePainter(frameId: 'frame_fire', radius: 50);
      expect(painter.shouldRepaint(otherFrame), isTrue);
      expect(painter.shouldRepaint(otherRadius), isTrue);
      expect(painter.shouldRepaint(painter), isFalse);
    });
  });
}
