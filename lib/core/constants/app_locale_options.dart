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

const String kLocaleTier1Title =
    'Kademe 1 — Mutlaka olması gerekenler (~%80+ küresel gelir)';
const String kLocaleTier2Title =
    'Kademe 2 — E-FIGS (Avrupa & Latin Amerika)';
const String kLocaleTier3Title =
    'Kademe 3 — Yükselen pazarlar (hacim & sıralama)';

/// Sıra: Tier 1 → 2 → 3 (ürün dokümanıyla aynı).
const List<AppLocaleOption> kAppLocaleOptions = <AppLocaleOption>[
  // —— Tier 1 ——
  AppLocaleOption(
    locale: Locale('en'),
    label: 'İngilizce',
    tier: 1,
    flag: '🇬🇧',
  ),
  AppLocaleOption(
    locale: Locale('zh', 'CN'),
    label: 'Çince (Basitleştirilmiş)',
    tier: 1,
    flag: '🇨🇳',
  ),
  AppLocaleOption(
    locale: Locale('ja'),
    label: 'Japonca',
    tier: 1,
    flag: '🇯🇵',
  ),
  AppLocaleOption(
    locale: Locale('ko'),
    label: 'Korece',
    tier: 1,
    flag: '🇰🇷',
  ),
  // —— Tier 2 E-FIGS ——
  AppLocaleOption(
    locale: Locale('fr'),
    label: 'Fransızca',
    tier: 2,
    flag: '🇫🇷',
  ),
  AppLocaleOption(
    locale: Locale('it'),
    label: 'İtalyanca',
    tier: 2,
    flag: '🇮🇹',
  ),
  AppLocaleOption(
    locale: Locale('de'),
    label: 'Almanca',
    tier: 2,
    flag: '🇩🇪',
  ),
  AppLocaleOption(
    locale: Locale('es'),
    label: 'İspanyolca',
    tier: 2,
    flag: '🇪🇸',
  ),
  AppLocaleOption(
    locale: Locale('pt', 'BR'),
    label: 'Portekizce (Brezilya)',
    tier: 2,
    flag: '🇧🇷',
  ),
  // —— Tier 3 ——
  AppLocaleOption(
    locale: Locale('ru'),
    label: 'Rusça',
    tier: 3,
    flag: '🇷🇺',
  ),
  AppLocaleOption(
    locale: Locale('tr'),
    label: 'Türkçe',
    tier: 3,
    flag: '🇹🇷',
  ),
  AppLocaleOption(
    locale: Locale('ar'),
    label: 'Arapça',
    tier: 3,
    flag: '🇸🇦',
  ),
  AppLocaleOption(
    locale: Locale('id'),
    label: 'Endonezce',
    tier: 3,
    flag: '🇮🇩',
  ),
  AppLocaleOption(
    locale: Locale('vi'),
    label: 'Vietnamca',
    tier: 3,
    flag: '🇻🇳',
  ),
  AppLocaleOption(
    locale: Locale('zh', 'TW'),
    label: 'Çince (Geleneksel)',
    tier: 3,
    flag: '🇹🇼',
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
