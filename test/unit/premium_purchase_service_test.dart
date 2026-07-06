import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_risk/features/premium/data/premium_purchase_service.dart';
import '../helpers/mock_firebase_functions.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>{});
  });

  group('PremiumPurchaseService', () {
    late MockInAppPurchase mockIap;
    late MockFirebaseFunctions mockFunctions;
    late PremiumPurchaseService service;

    setUp(() {
      mockIap = MockInAppPurchase();
      mockFunctions = MockFirebaseFunctions();
      service = PremiumPurchaseService(iap: mockIap, functions: mockFunctions);
    });

    tearDown(() async {
      await service.dispose();
    });

    test('init mağaza yoksa boş ürün listesi yayınlar', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => false);

      final emitted = <List<ProductDetails>>[];
      final sub = service.availableProductsStream.listen(emitted.add);
      await service.init();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last, isEmpty);
      await sub.cancel();
    });

    test('buyLifetimePremium ürün yoksa hata fırlatır', () async {
      when(() => mockIap.queryProductDetails(any())).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: [],
          notFoundIDs: [],
        ),
      );

      expect(
        () => service.buyLifetimePremium(),
        throwsA(isA<Exception>()),
      );
    });

    test('restorePurchases IAP restore çağrısı yapar', () async {
      when(() => mockIap.restorePurchases()).thenAnswer((_) async {});

      await service.restorePurchases();

      verify(() => mockIap.restorePurchases()).called(1);
    });
  });
}
