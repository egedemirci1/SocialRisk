import 'package:flutter/material.dart';

/// Ayarlarda gösterilecek dil satırı (kademe + etiket + bayrak).
class AppLocaleOption {
  const AppLocaleOption({
    required this.locale,
    required this.label,
    required this.tier,
    required this.flag,
  });

  final Locale locale;
  final String label;
  final int tier;
  final String flag;
}

const List<AppLocaleOption> kAppLocaleOptions = <AppLocaleOption>[
  AppLocaleOption(
    locale: Locale('tr'),
    label: 'Türkçe',
    tier: 1,
    flag: '🇹🇷',
  ),
  AppLocaleOption(
    locale: Locale('en'),
    label: 'English',
    tier: 1,
    flag: '🇬🇧',
  ),
];

bool localeMatchesSelection(Locale a, Locale b) =>
    a.languageCode == b.languageCode &&
    (a.countryCode ?? '') == (b.countryCode ?? '');

/// Seçim listede yoksa (eski kayıt vb.) önce dil kodu, sonra [tr].
Locale resolveLocaleForList(Locale preferred) {
  for (final o in kAppLocaleOptions) {
    if (localeMatchesSelection(o.locale, preferred)) return o.locale;
  }
  for (final o in kAppLocaleOptions) {
    if (o.locale.languageCode == preferred.languageCode) return o.locale;
  }
  return const Locale('tr');
}

/// Şimdilik yalnızca [tr] ve [en] ARB var; diğer tercihler kayıtlı kalır, UI dili buna göre.
Locale resolveMaterialLocale(Locale preference) =>
    preference.languageCode == 'tr' ? const Locale('tr') : const Locale('en');
