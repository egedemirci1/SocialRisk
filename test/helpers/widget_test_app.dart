import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_risk/core/providers/shared_prefs_provider.dart';
import 'package:social_risk/features/premium/data/premium_purchase_service.dart';
import 'package:social_risk/features/premium/providers/premium_provider.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import 'test_shared_preferences.dart';

export 'test_shared_preferences.dart';

const testLocale = Locale('tr');

const testLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class MockPremiumPurchaseService extends Mock implements PremiumPurchaseService {}

MockPremiumPurchaseService? _mockPremiumPurchaseService;

void ensureTestMocks() {
  final mock = _mockPremiumPurchaseService ??= MockPremiumPurchaseService();
  when(() => mock.init()).thenAnswer((_) async {});
  when(() => mock.dispose()).thenAnswer((_) async {});
  when(() => mock.availableProductsStream).thenAnswer((_) => const Stream.empty());
  when(() => mock.buyLifetimePremium()).thenAnswer((_) async {});
  when(() => mock.restorePurchases()).thenAnswer((_) async {});
}

final defaultWidgetTestOverrides = [
  sharedPreferencesProvider.overrideWithValue(testSharedPreferences),
  premiumPurchaseServiceProvider.overrideWithValue(
    _mockPremiumPurchaseService ?? MockPremiumPurchaseService(),
  ),
];

Widget wrapWithLocalizedApp({
  required Widget child,
  overrides = const [],
  Size size = const Size(600, 900),
}) {
  ensureTestMocks();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(testSharedPreferences),
      premiumPurchaseServiceProvider.overrideWithValue(_mockPremiumPurchaseService!),
      ...overrides,
    ],
    child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    ),
  );
}

Widget wrapWithLocalizedRouter({
  required GoRouter routerConfig,
  overrides = const [],
}) {
  ensureTestMocks();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(testSharedPreferences),
      premiumPurchaseServiceProvider.overrideWithValue(_mockPremiumPurchaseService!),
      ...overrides,
    ],
    child: MaterialApp.router(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: routerConfig,
    ),
  );
}
