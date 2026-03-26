import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_locale_options.dart';

/// Ayarlardan seçilen dil (tüm katalog). [AppLocalizations] şimdilik yalnızca tr/en.
class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('tr');

  void setLocale(Locale locale) {
    state = resolveLocaleForList(locale);
  }
}

final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale>(AppLocaleNotifier.new);

/// Geriye dönük uyumluluk ve context üzerinden erişim için yardımcı sınıf.
class LocaleProvider {
  static Locale of(BuildContext context) {
    return Localizations.localeOf(context);
  }
}
