import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_risk/core/providers/shared_prefs_provider.dart';
import 'package:social_risk/features/premium/data/premium_purchase_service.dart';
import 'package:social_risk/features/premium/providers/premium_provider.dart';
import 'package:social_risk/l10n/app_localizations.dart';

const testLocale = Locale('tr');

const testLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class TestSharedPreferences extends Fake implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }
}

class MockPremiumPurchaseService extends Mock implements PremiumPurchaseService {}

final _testSharedPreferences = TestSharedPreferences();
MockPremiumPurchaseService? _mockPremiumPurchaseService;

void _ensureTestMocks() {
  final mock = _mockPremiumPurchaseService ??= MockPremiumPurchaseService();
  when(() => mock.init()).thenAnswer((_) async {});
  when(() => mock.dispose()).thenAnswer((_) async {});
  when(() => mock.availableProductsStream).thenAnswer((_) => const Stream.empty());
  when(() => mock.buyLifetimePremium()).thenAnswer((_) async {});
  when(() => mock.restorePurchases()).thenAnswer((_) async {});
}

final defaultWidgetTestOverrides = [
  sharedPreferencesProvider.overrideWithValue(_testSharedPreferences),
  premiumPurchaseServiceProvider.overrideWithValue(
    _mockPremiumPurchaseService ?? MockPremiumPurchaseService(),
  ),
];

Widget wrapWithLocalizedApp({
  required Widget child,
  overrides = const [],
  Size size = const Size(600, 900),
}) {
  _ensureTestMocks();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_testSharedPreferences),
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
  _ensureTestMocks();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_testSharedPreferences),
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
