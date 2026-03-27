import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import '../constants/app_locale_options.dart';

/// Ayarlardan seçilen dil (tüm katalog). [AppLocalizations] şimdilik yalnızca tr/en.
class AppLocaleNotifier extends Notifier<Locale> {
  static const _key = 'app_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs.getString(_key);
    
    if (savedCode != null) {
      return Locale(savedCode);
    }

    // İlk açılış: Cihaz dilini kontrol et. tr ise tr, değilse en.
    final deviceLocale = PlatformDispatcher.instance.locale;
    final initialLocale = deviceLocale.languageCode == 'tr' 
        ? const Locale('tr') 
        : const Locale('en');
    
    // İlk değeri kaydet (isteğe bağlı, ama "son ayar seçili kalmalı" için mantıklı)
    // Build içinde senkron kaydetmek sorun yaratabilir, o yüzden sadece döndürüyoruz.
    // Bir sonraki setLocale çağrısında zaten kaydedilecek.
    return initialLocale;
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newState = resolveLocaleForList(locale);
    await prefs.setString(_key, newState.languageCode);
    state = newState;
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
