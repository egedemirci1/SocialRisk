import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/constants/app_locale_options.dart';

void main() {
  group('AppLocaleOptions', () {
    test('localeMatchesSelection compares language and country', () {
      expect(
        localeMatchesSelection(const Locale('tr'), const Locale('tr')),
        isTrue,
      );
      expect(
        localeMatchesSelection(const Locale('en', 'US'), const Locale('en', 'US')),
        isTrue,
      );
      expect(
        localeMatchesSelection(const Locale('tr'), const Locale('en')),
        isFalse,
      );
    });

    test('resolveLocaleForList returns known locale', () {
      expect(
        resolveLocaleForList(const Locale('en')),
        const Locale('en'),
      );
    });

    test('resolveLocaleForList falls back to language code match', () {
      expect(
        resolveLocaleForList(const Locale('en', 'US')),
        const Locale('en'),
      );
    });

    test('resolveLocaleForList falls back to tr for unknown language', () {
      expect(
        resolveLocaleForList(const Locale('de')),
        const Locale('tr'),
      );
    });

    test('resolveMaterialLocale maps tr and non-tr', () {
      expect(
        resolveMaterialLocale(const Locale('tr')),
        const Locale('tr'),
      );
      expect(
        resolveMaterialLocale(const Locale('de')),
        const Locale('en'),
      );
    });

    test('kAppLocaleOptions contains tr and en', () {
      final codes = kAppLocaleOptions.map((o) => o.locale.languageCode).toSet();
      expect(codes, containsAll(['tr', 'en']));
    });
  });
}
