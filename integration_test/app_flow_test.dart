import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:social_risk/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kritik Akış - Integration Tests', () {
    testWidgets('Uygulama başarıyla başlatılabilmeli', (WidgetTester tester) async {
      // Arrange
      app.main();

      // Act
      // Asenkron işlemlerin bitmesi için bekliyoruz
      await tester.pumpAndSettle();

      // Assert
      // Uygulamanın root MaterialApp veya router yapısını bulmasını bekleriz.
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
