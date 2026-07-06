import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/core/providers/locale_provider.dart';
import '../helpers/test_provider_overrides.dart';
import '../helpers/test_shared_preferences.dart';

void main() {
  setUp(() async {
    await testSharedPreferences.clear();
  });

  group('AppLocaleNotifier', () {
    test('build returns saved locale from preferences', () async {
      await testSharedPreferences.setString('app_locale', 'en');

      final container = ProviderContainer(
        overrides: unitTestOverrides(),
      );
      addTearDown(container.dispose);

      expect(container.read(appLocaleProvider), const Locale('en'));
    });

    test('setLocale persists language code and updates state', () async {
      await testSharedPreferences.clear();

      final container = ProviderContainer(
        overrides: unitTestOverrides(),
      );
      addTearDown(container.dispose);

      await container.read(appLocaleProvider.notifier).setLocale(const Locale('en'));

      expect(container.read(appLocaleProvider), const Locale('en'));
      expect(testSharedPreferences.getString('app_locale'), 'en');
    });

    test('setLocale resolves unsupported locale to tr', () async {
      final container = ProviderContainer(
        overrides: unitTestOverrides(),
      );
      addTearDown(container.dispose);

      await container.read(appLocaleProvider.notifier).setLocale(const Locale('de'));

      expect(container.read(appLocaleProvider), const Locale('tr'));
      expect(testSharedPreferences.getString('app_locale'), 'tr');
    });
  });
}
